{% macro create_dcm_project(database, schemas, roles, project_owner_role) %}

  -- Dynamic Role References from Configuration Map
  {% set dba_admin_role = roles['DBA_ADMIN'] %}
  {% set dba_fr_role = roles['DBA_FR'] %}
  {% set accountadmin_role = project_owner_role %}

  -- Grants for logical role: DBA_ADMIN
  GRANT USAGE ON DATABASE {{ database }} TO ROLE {{ dba_admin_role }};

  {% for schema in schemas %}
    {% set full_schema = database ~ '.' ~ schema %}
    GRANT USAGE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE DCM PROJECT ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE DYNAMIC TABLE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE FILE FORMAT ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE FUNCTION ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE PROCEDURE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE STAGE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE STREAM ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE TABLE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE TASK ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT CREATE VIEW ON SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT SELECT ON ALL TABLES IN SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT SELECT ON FUTURE TABLES IN SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT SELECT ON ALL VIEWS IN SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
    GRANT SELECT ON FUTURE VIEWS IN SCHEMA {{ full_schema }} TO ROLE {{ dba_admin_role }};
  {% endfor %}

  -- Grants for logical role: DBA_FR
  GRANT USAGE ON DATABASE {{ database }} TO ROLE {{ dba_fr_role }};

  {% for schema in schemas %}
    {% set full_schema = database ~ '.' ~ schema %}
    GRANT USAGE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_fr_role }};
    GRANT CREATE DCM PROJECT ON SCHEMA {{ full_schema }} TO ROLE {{ dba_fr_role }};
    GRANT CREATE DYNAMIC TABLE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_fr_role }};
    GRANT CREATE FILE FORMAT ON SCHEMA {{ full_schema }} TO ROLE {{ dba_fr_role }};
    GRANT CREATE FUNCTION ON SCHEMA {{ full_schema }} TO ROLE {{ dba_fr_role }};
    GRANT CREATE PROCEDURE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_fr_role }};
    GRANT CREATE STAGE ON SCHEMA {{ full_schema }} TO ROLE {{ dba_fr_role }};
  {% endfor %}

  -- Role Hierarchy Grants (Uses environment-scoped role names)
  GRANT ROLE {{ dba_admin_role }} TO ROLE {{ dba_fr_role }};
  {% if accountadmin_role %}
  GRANT ROLE {{ dba_fr_role }} TO ROLE {{ accountadmin_role }};
  {% endif %}

{% endmacro %}