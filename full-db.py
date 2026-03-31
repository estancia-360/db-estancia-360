import os
import re

ROOT_DIR = "./"  # Carpeta raíz de tu proyecto
MAIN_INIT = os.path.join(ROOT_DIR, "init.sql")
OUTPUT_FILE = "db-estancia-360.sql"

visited_files = set()

def read_sql_file(file_path):
    """Lee un archivo SQL ignorando líneas vacías y líneas \i, ignorando errores de codificación"""
    abs_path = os.path.abspath(file_path)
    if abs_path in visited_files:
        return None
    visited_files.add(abs_path)

    if not os.path.exists(abs_path):
        return None

    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = [line.rstrip() for line in f if line.strip() and not line.strip().startswith(r'\i')]
    except Exception:
        return None

    if not lines:
        return None
    return lines

def process_directory(dir_path):
    """
    Procesa todos los archivos SQL de una carpeta y devuelve un bloque si hay contenido.
    """
    block_lines = []
    dir_name = os.path.basename(dir_path)

    for f in sorted(os.listdir(dir_path)):
        file_path = os.path.join(dir_path, f)
        if f.endswith(".sql") and os.path.isfile(file_path):
            content = read_sql_file(file_path)
            if content:
                if not block_lines:
                    block_lines.append(f"\n-- INICIO DEL BLOQUE DE CARPETA: {dir_name}")
                block_lines.extend(content)

    if block_lines:
        block_lines.append(f"-- FIN DEL BLOQUE DE CARPETA: {dir_name}\n")
        return block_lines
    return None

def main():
    if os.path.exists(OUTPUT_FILE):
        os.remove(OUTPUT_FILE)

    final_lines = [
        "-- ==========================================================",
        "-- SCRIPT COMPLETO GENERADO AUTOMÁTICAMENTE (SEGÚN init.sql PRINCIPAL)",
        "-- ==========================================================\n"
    ]

    # Leer init.sql principal
    try:
        with open(MAIN_INIT, 'r', encoding='utf-8', errors='ignore') as f:
            main_lines = f.readlines()
    except Exception:
        print("Error leyendo init.sql principal")
        return

    # Agregar contenido del init.sql principal, ignorando \i
    main_content = [line.rstrip() for line in main_lines if line.strip() and not line.strip().startswith(r'\i')]
    if main_content:
        final_lines.extend(main_content)

    # Buscar carpetas referenciadas en el init.sql principal mediante \i carpeta/init.sql
    folder_refs = []
    for line in main_lines:
        match = re.match(r'^\\i\s+(\S+)/init\.sql', line.strip())
        if match:
            folder_name = match.group(1)
            folder_path = os.path.join(ROOT_DIR, folder_name)
            if os.path.isdir(folder_path):
                folder_refs.append(folder_path)

    # Procesar solo las carpetas referenciadas
    for folder_path in folder_refs:
        block = process_directory(folder_path)
        if block:
            final_lines.extend(block)

    final_lines.append("-- FIN DEL SCRIPT\n")

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("\n".join(final_lines))

    print(f"Script final generado en: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
