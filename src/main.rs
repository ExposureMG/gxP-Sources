use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use std::fs::{self, File};
use std::io::{Write, BufRead, BufReader};
use std::path::Path;
use std::process::Command;
use std::env;
use tempfile::NamedTempFile;

#[derive(Parser)]
#[command(name = "gxp-converter")]
#[command(about = "Universal patch converter and builder for gxBuild", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Diff two binaries and generate a GXS patch
    Diff {
        /// Path to the clean binary
        clean: String,
        /// Path to the patched binary
        patched: String,
        /// Base offset for the GXS addresses (e.g. 0x1000)
        #[arg(short, long, default_value = "0x0")]
        offset: String,
        /// Title for the GXS patch
        #[arg(short, long, default_value = "Custom Patch")]
        title: String,
    },
    /// Convert an xeBuild multi-section binary patch to GXS
    Convert {
        /// Path to the xeBuild binary patch (.bin / .pkg)
        input: String,
        /// Output directory for .gxs files
        #[arg(short, long, default_value = ".")]
        out_dir: String,
        /// Treat input as an addon patch (no 0xFFFFFFFF delimiters)
        #[arg(short, long)]
        addon: bool,
    },
    /// Pack GXS sections into a GXP binary
    Pack {
        /// Directory containing part1.gxs, part2.gxs, etc.
        input_dir: String,
        /// Output GXP file path
        #[arg(short, long)]
        output: String,
        /// Target Kernel Version (e.g. 17559)
        #[arg(short, long, default_value = "0")]
        kernel: u32,
        /// Motherboard Enum (0 = Any)
        #[arg(short, long, default_value = "0")]
        motherboard: u16,
        /// Patch Type (0=4RGH, 1=5JTAG, 2=4JTAG, 3=3RGH, 4=Standalone, 5=Addon)
        #[arg(short, long, default_value = "0")]
        patch_type: u8,
        /// Target Bootloader for Standalone/Addon
        #[arg(short, long, default_value = "0")]
        bootloader: u8,
        /// Injection offset for Addon patches
        #[arg(long, default_value = "0")]
        offset: u32,
    },
}

struct GxsRecord {
    addr: u32,
    data: Vec<u8>,
}

struct AsmSection {
    addr: u32,
    code: String,
}

fn hex_format(data: &[u8]) -> String {
    data.iter()
        .map(|b| format!("{:02X}", b))
        .collect::<Vec<String>>()
        .join(" ")
}

fn parse_gxs_line(line: &str) -> Option<GxsRecord> {
    let line = line.trim();
    if line.is_empty() || line.starts_with('#') {
        return None;
    }

    let parts: Vec<&str> = line.split(':').collect();
    if parts.len() < 2 {
        return None;
    }

    let addr_str = parts[0].trim();
    let addr = if addr_str.starts_with("0x") {
        u32::from_str_radix(&addr_str[2..], 16).ok()?
    } else {
        addr_str.parse().ok()?
    };

    let data_str = parts[1].trim();
    let data = data_str
        .split_whitespace()
        .filter_map(|s| u8::from_str_radix(s, 16).ok())
        .collect();

    Some(GxsRecord { addr, data })
}

fn parse_asm_section(lines: &[&str], start_idx: usize) -> Option<AsmSection> {
    if start_idx >= lines.len() {
        return None;
    }

    let first_line = lines[start_idx].trim();
    if !first_line.starts_with("[ASM]") {
        return None;
    }

    // Extract address from [ASM] 0xADDR:
    let addr_part = first_line.strip_prefix("[ASM]")?.trim();
    let addr_str = addr_part.strip_suffix(':')?.trim();
    let addr = if addr_str.starts_with("0x") {
        u32::from_str_radix(&addr_str[2..], 16).ok()?
    } else {
        addr_str.parse().ok()?
    };

    // Collect ASM code lines
    let mut code_lines = Vec::new();
    for &line in &lines[start_idx + 1..] {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }
        // Stop at [!ASM] end marker or next section/directive
        if trimmed.starts_with("[!ASM]") || trimmed.starts_with('[') || trimmed.starts_with('.') {
            break;
        }
        code_lines.push(trimmed);
    }

    if code_lines.is_empty() {
        return None;
    }

    Some(AsmSection {
        addr,
        code: code_lines.join("\n"),
    })
}

fn compile_asm_section(asm: &AsmSection) -> Result<Vec<u8>> {
    let os = env::consts::OS;
    
    match os {
        "linux" => compile_asm_linux(asm),
        "windows" => compile_asm_windows(asm),
        _ => Err(anyhow::anyhow!("ASM compilation not supported on {}", os)),
    }
}

fn compile_asm_linux(asm: &AsmSection) -> Result<Vec<u8>> {
    // Use xenon-as directly with proper syntax
    try_assembler_compilation(asm)
}


fn try_assembler_compilation(asm: &AsmSection) -> Result<Vec<u8>> {
    // Create temporary assembly file
    let asm_file = NamedTempFile::with_suffix(".s")?;
    let obj_file = NamedTempFile::with_suffix(".o")?;
    let bin_file = NamedTempFile::with_suffix(".bin")?;
    
    // Write assembly with proper directives for xenon assembler
    // Include the macro definitions that are used in working txt files
    let asm_content = format!(
        ".set KBASE, 0x80000000
.set hrmor, 313
.set ctr, 9
.set lr, 8
.text
.globl _start
_start:
{}
",
        asm.code
    );
    fs::write(asm_file.path(), asm_content)?;
    
    // Compile with local xenon-as (Linux version)
    let output = Command::new("./bin/xenon-as")
        .arg("-o")
        .arg(obj_file.path())
        .arg(asm_file.path())
        .output()
        .context("Failed to run ./bin/xenon-as")?;
    
    if !output.status.success() {
        return Err(anyhow::anyhow!("Assembly compilation failed: {}", String::from_utf8_lossy(&output.stderr)));
    }
    
    // Extract raw binary with local xenon-objcopy (Linux version)
    let output = Command::new("./bin/xenon-objcopy")
        .arg("-O")
        .arg("binary")
        .arg(obj_file.path())
        .arg(bin_file.path())
        .output()
        .context("Failed to run ./bin/xenon-objcopy")?;
    
    if !output.status.success() {
        return Err(anyhow::anyhow!("Object copy failed: {}", String::from_utf8_lossy(&output.stderr)));
    }
    
    fs::read(bin_file.path()).context("Failed to read compiled binary")
}

fn compile_asm_windows(asm: &AsmSection) -> Result<Vec<u8>> {
    // Create temporary assembly file
    let asm_file = NamedTempFile::with_suffix(".s")?;
    let obj_file = NamedTempFile::with_suffix(".o")?;
    let bin_file = NamedTempFile::with_suffix(".bin")?;
    
    // Write assembly with proper directives for xenon assembler
    let asm_content = format!(
        "\n.set KBASE, 0x80000000\n.set hrmor, 313\n.set ctr, 9\n.set lr, 8\n    .text\n    .globl _start\n_start:\n{}\n",
        asm.code
    );
    fs::write(asm_file.path(), asm_content)?;
    
    // Compile with local xenon-as.exe
    let output = Command::new("./bin/xenon-as.exe")
        .arg("-o")
        .arg(obj_file.path())
        .arg(asm_file.path())
        .output()
        .context("Failed to run ./bin/xenon-as.exe")?;
    
    if !output.status.success() {
        return Err(anyhow::anyhow!("Assembly compilation failed: {}", String::from_utf8_lossy(&output.stderr)));
    }
    
    // Extract raw binary with local xenon-objcopy.exe
    let output = Command::new("./bin/xenon-objcopy.exe")
        .arg("-O")
        .arg("binary")
        .arg(obj_file.path())
        .arg(bin_file.path())
        .output()
        .context("Failed to run ./bin/xenon-objcopy.exe")?;
    
    if !output.status.success() {
        return Err(anyhow::anyhow!("Object copy failed: {}", String::from_utf8_lossy(&output.stderr)));
    }
    
    fs::read(bin_file.path()).context("Failed to read compiled binary")
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Diff { clean, patched, offset, title } => {
            let offset_val = if offset.starts_with("0x") {
                u32::from_str_radix(&offset[2..], 16)?
            } else {
                offset.parse()?
            };

            let clean_data = fs::read(&clean).with_context(|| format!("Failed to read {}", clean))?;
            let patched_data = fs::read(&patched).with_context(|| format!("Failed to read {}", patched))?;

            let len = clean_data.len().min(patched_data.len());
            let mut diffs = Vec::new();
            let mut current_block: Option<(usize, Vec<u8>)> = None;

            for i in 0..len {
                if clean_data[i] != patched_data[i] {
                    match current_block {
                        Some((ref mut _start, ref mut data)) => {
                            data.push(patched_data[i]);
                        }
                        None => {
                            current_block = Some((i, vec![patched_data[i]]));
                        }
                    }
                } else {
                    if let Some((start, data)) = current_block.take() {
                        diffs.push((start, data));
                    }
                }
            }
            if let Some((start, data)) = current_block.take() {
                diffs.push((start, data));
            }

            println!("# GXP-Source (GXS): {}", title);
            for (start, data) in diffs {
                let addr = offset_val + start as u32;
                println!("0x{:04X}: {}", addr, hex_format(&data));
            }
        }
        Commands::Convert { input, out_dir, addon } => {
            let data = fs::read(&input).with_context(|| format!("Failed to read {}", input))?;
            let out_path = Path::new(&out_dir);
            if !out_path.exists() {
                fs::create_dir_all(out_path)?;
            }

            let mut pos = 0;
            let mut part_idx = 1;
            let mut current_part_records = Vec::new();

            while pos + 8 <= data.len() {
                let addr = u32::from_be_bytes(data[pos..pos+4].try_into()?);
                if addr == 0xFFFFFFFF {
                    if !current_part_records.is_empty() {
                        write_part(&out_path, part_idx, &current_part_records, &input)?;
                        current_part_records.clear();
                        part_idx += 1;
                    }
                    pos += 4;
                    continue;
                }

                let count = u32::from_be_bytes(data[pos+4..pos+8].try_into()?);
                pos += 8;
                let size = (count * 4) as usize;
                
                if pos + size > data.len() {
                    return Err(anyhow::anyhow!("Unexpected end of file at pos {}", pos));
                }

                let patch_data = &data[pos..pos+size];
                current_part_records.push((addr, patch_data.to_vec()));
                pos += size;

                if addon && pos >= data.len() {
                    break;
                }
            }

            if !current_part_records.is_empty() {
                write_part(&out_path, part_idx, &current_part_records, &input)?;
            }
        }
        Commands::Pack { input_dir, output, kernel, motherboard, patch_type, bootloader, offset } => {
            let mut gxp_file = File::create(&output)?;
            
            // 1. Write Header (16 bytes)
            gxp_file.write_all(b"GXP\0")?;
            gxp_file.write_all(&kernel.to_be_bytes())?;
            gxp_file.write_all(&motherboard.to_be_bytes())?;
            gxp_file.write_all(&[patch_type])?;
            gxp_file.write_all(&[bootloader])?;
            gxp_file.write_all(&offset.to_be_bytes())?;

            // 2. Process GXS Files
            let mut part_idx = 1;
            loop {
                let part_name = format!("part{}.gxs", part_idx);
                let part_path = Path::new(&input_dir).join(&part_name);
                if !part_path.exists() {
                    break;
                }

                println!("Packing {}...", part_name);
                let file = File::open(part_path)?;
                let reader = BufReader::new(file);
                
                let mut records = Vec::new();
                let mut lines = Vec::new();
                for line in reader.lines() {
                    lines.push(line?);
                }
                
                // Parse GXS lines and ASM sections
                let mut i = 0;
                while i < lines.len() {
                    let line = lines[i].trim();
                    
                    if line.starts_with("[ASM]") {
                        // Parse ASM section
                        if let Some(asm_section) = parse_asm_section(&lines.iter().map(|s| s.as_str()).collect::<Vec<_>>(), i) {
                            match compile_asm_section(&asm_section) {
                                Ok(compiled_data) => {
                                    records.push(GxsRecord {
                                        addr: asm_section.addr,
                                        data: compiled_data,
                                    });
                                    println!("  Compiled ASM at 0x{:08X}", asm_section.addr);
                                }
                                Err(e) => {
                                    return Err(anyhow::anyhow!("Failed to compile ASM at 0x{:08X}: {}", asm_section.addr, e));
                                }
                            }
                            // Skip to next section
                            i += 1;
                            while i < lines.len() {
                                let next_line = lines[i].trim();
                                if next_line.is_empty() || next_line.starts_with('#') {
                                    i += 1;
                                    continue;
                                }
                                if next_line.starts_with('[') || next_line.starts_with('.') {
                                    break;
                                }
                                i += 1;
                            }
                        } else {
                            i += 1;
                        }
                    } else if let Some(rec) = parse_gxs_line(line) {
                        records.push(rec);
                        i += 1;
                    } else {
                        i += 1;
                    }
                }

                // Compile records to binary blocks
                // Logic: Merge contiguous addresses into single 4-byte word blocks
                // For simplicity and compatibility with xeBuild format, we group into 4-byte aligned blocks
                let compiled_blocks = compile_gxs_to_blocks(records);
                
                for (addr, data) in compiled_blocks {
                    gxp_file.write_all(&addr.to_be_bytes())?;
                    let word_count = (data.len() / 4) as u32;
                    gxp_file.write_all(&word_count.to_be_bytes())?;
                    gxp_file.write_all(&data)?;
                }

                // End of section
                gxp_file.write_all(&[0xFF, 0xFF, 0xFF, 0xFF])?;
                part_idx += 1;
            }

            println!("GXP created successfully: {}", output);
        }
    }

    Ok(())
}

fn compile_gxs_to_blocks(mut records: Vec<GxsRecord>) -> Vec<(u32, Vec<u8>)> {
    if records.is_empty() { return vec![]; }
    records.sort_by_key(|r| r.addr);

    let mut blocks = Vec::new();
    let mut current_addr = records[0].addr;
    let mut current_data = Vec::new();

    for rec in records {
        if !current_data.is_empty() && rec.addr != current_addr + current_data.len() as u32 {
            // Finish current block (pad to 4 bytes)
            while current_data.len() % 4 != 0 { current_data.push(0); }
            blocks.push((current_addr, current_data));
            current_addr = rec.addr;
            current_data = Vec::new();
        }
        current_data.extend(rec.data);
    }
    
    if !current_data.is_empty() {
        while current_data.len() % 4 != 0 { current_data.push(0); }
        blocks.push((current_addr, current_data));
    }

    blocks
}

fn write_part(out_dir: &Path, idx: usize, records: &[(u32, Vec<u8>)], original: &str) -> Result<()> {
    let filename = format!("part{}.gxs", idx);
    let mut file = File::create(out_dir.join(&filename))?;
    writeln!(file, "# GXP-Source (GXS): Part {} from {}", idx, original)?;
    writeln!(file, "# Format: [Address]: [Hex Data...]")?;
    writeln!(file, "")?;

    for (addr, data) in records {
        writeln!(file, "0x{:04X}: {}", addr, hex_format(data))?;
    }
    println!("Created {}", filename);
    Ok(())
}
