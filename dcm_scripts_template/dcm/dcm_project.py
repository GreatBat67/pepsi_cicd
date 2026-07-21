from pathlib import Path
import sys
import importlib

sys.dont_write_bytecode = True

ROOT = Path.cwd().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import config.config as cfg
importlib.reload(cfg)

config = cfg.config
LOGS_DIR = cfg.LOGS_DIR

# ============================================================
# CONFIG
# ============================================================
BRANCH_DATA = config.branch_data
ADMIN_ROLE = config.admin_role.upper()

# Find the branch where is_default_target is true (to act as the metadata hub)
target_config = {}
for branch_name, branch_cfg in BRANCH_DATA.items():
    if isinstance(branch_cfg, dict) and branch_cfg.get("is_default_target", False):
        target_config = branch_cfg
        break

if not target_config:
    raise RuntimeError("No branch with is_default_target: true found in project_config.yml")

# Hardcoding the schema as requested, pulling the DB from the config (CICD_METADATA)
sf_databases = target_config.get("sf_databases", ["CICD_METADATA"])
metadata_db = sf_databases[0].upper() if sf_databases else "CICD_METADATA"
metadata_schema = "DCM_CONFIG"

OUTPUT_FILE = LOGS_DIR / "create_dcm_projects.sql"

# ============================================================
# GENERATE SQL
# ============================================================
sql = []

sql.append("-- ====================================================")
sql.append("-- CREATE DCM PROJECTS FOR ALL ENVIRONMENTS")
sql.append("-- ====================================================")
sql.append("")

sql.append(f"USE ROLE {ADMIN_ROLE};")
sql.append("")

sql.append(f"USE DATABASE {metadata_db};")
sql.append(f"CREATE SCHEMA IF NOT EXISTS {metadata_db}.{metadata_schema};")
sql.append(f"USE SCHEMA {metadata_db}.{metadata_schema};")
sql.append("")

# Loop through all branches to create their specific DCM targets
for branch_name, branch_cfg in BRANCH_DATA.items():
    if not isinstance(branch_cfg, dict):
        continue

    dcm_target = branch_cfg.get("dcm_target")
    
    # Skip if the branch doesn't have a target or is the metadata branch itself
    if not dcm_target or branch_cfg.get("is_default_target", False):
        continue

    dcm_target_upper = dcm_target.upper()

    sql.append(f"-- Project for {branch_name.upper()} environment")
    sql.append(f"CREATE DCM PROJECT IF NOT EXISTS {metadata_db}.{metadata_schema}.{dcm_target_upper};")
    sql.append("")

# ============================================================
# WRITE SQL
# ============================================================
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write("\n".join(sql))

print("=" * 60)
print("DCM Project creation SQL generated successfully.")
print(f"Output: {OUTPUT_FILE.resolve()}")
print("=" * 60)