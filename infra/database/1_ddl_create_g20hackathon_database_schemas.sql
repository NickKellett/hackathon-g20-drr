-- Original Work: Copyright 2025 OS-Climate
-- Modifications Copyright 2025 Nicholas Kellett

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- PHYRISK EXAMPLE DATABASE STRUCTURE
-- Based on OS-Climate's Physical Risk & Resilience Metadata schemas located at:
-- https://github.com/os-climate/osc-physrisk-metadata
-- Intended to help standardize glossary/metadata as well as field core_names and constraints
-- to align with phys-risk/geo-indexer/other related initiatives and 
-- speed up application development, help internationalize and display the results of analyses, and more.
-- The backend schema User and Tenant tables are derived from ASP.NET Boilerplate tables (https://aspnetboilerplate.com/). That code is available under the MIT license, here: https://github.com/aspnetboilerplate/aspnetboilerplate

-- SETUP EXTENSIONS
CREATE EXTENSION IF NOT EXISTS postgis; -- used for geolocation
CREATE EXTENSION IF NOT EXISTS h3; -- used for Uber H3 geolocation
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- used for random UUID generation

-- SETUP SCHEMAS
CREATE SCHEMA IF NOT EXISTS g20hackathon_backend;
CREATE SCHEMA IF NOT EXISTS g20hackathon_org;
CREATE SCHEMA IF NOT EXISTS g20hackathon_model;
CREATE SCHEMA IF NOT EXISTS g20hackathon_structure;
CREATE SCHEMA IF NOT EXISTS g20hackathon_structure;
CREATE SCHEMA IF NOT EXISTS g20hackathon_analysis;

-- SETUP TABLES
-- SCHEMA g20hackathon_backend

CREATE TABLE g20hackathon_backend.user (
	core_id bigint NOT NULL,
	core_temporal_datetime_utc_created       timestamptz  NOT NULL  ,
	core_user_creator_id      bigint    ,
	core_temporal_datetime_utc_last_modified timestamptz    ,
	core_user_last_modifier_id bigint    ,
	core_is_deleted          boolean  NOT NULL  ,
	core_user_deleter_id      bigint    ,
	core_temporal_datetime_utc_deleted       timestamptz    ,
	core_user_name VARCHAR(255) NOT NULL,
	core_tenant_id INTEGER,
	email_address VARCHAR(255) NOT NULL,
	core_name        VARCHAR(255)  NOT NULL  ,
	core_surname        VARCHAR(255)  NOT NULL  ,
	core_is_active       boolean  NOT NULL  ,
	PRIMARY KEY (core_id)
);

ALTER TABLE g20hackathon_backend.user
	ADD FOREIGN KEY (core_user_creator_id) 
	REFERENCES g20hackathon_backend.user (core_id);

ALTER TABLE g20hackathon_backend.user
	ADD FOREIGN KEY (core_user_deleter_id) 
	REFERENCES g20hackathon_backend.user (core_id);

ALTER TABLE g20hackathon_backend.user
	ADD FOREIGN KEY (core_user_last_modifier_id) 
	REFERENCES g20hackathon_backend.user (core_id);

CREATE INDEX "ix_g20hackathon_backend_users_core_user_creator_id" ON g20hackathon_backend.user USING btree (core_user_creator_id);
CREATE INDEX "ix_g20hackathon_backend_users_core_user_deleter_id" ON g20hackathon_backend.user USING btree (core_user_deleter_id);
CREATE INDEX "ix_g20hackathon_backend_users_core_user_last_modifier_id" ON g20hackathon_backend.user USING btree (core_user_last_modifier_id);
CREATE INDEX "ix_g20hackathon_backend_users_email_address" ON g20hackathon_backend.user USING btree (core_tenant_id, email_address);
CREATE INDEX "ix_g20hackathon_backend_users_core_tenant_id_core_user_name" ON g20hackathon_backend.user USING btree (core_tenant_id, core_user_name);

COMMENT ON TABLE g20hackathon_backend.user IS 'Stores user information.';

CREATE TABLE g20hackathon_backend.tenant (
	core_id bigint NOT NULL,
	core_temporal_datetime_utc_created       timestamptz  NOT NULL  ,
	core_user_creator_id      bigint    ,
	core_temporal_datetime_utc_last_modified timestamptz    ,
	core_user_last_modifier_id bigint    ,
	core_is_deleted          boolean  NOT NULL  ,
	core_user_deleter_id      bigint    ,
	core_temporal_datetime_utc_deleted       timestamptz    ,
	core_name varchar(64) NOT NULL,
	core_tenancy_name VARCHAR(255) NOT NULL,
	core_is_active       boolean  NOT NULL  ,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_tenants_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_tenants_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_tenants_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id)
);

CREATE INDEX "ix_g20hackathon_backend_tenants_core_temporal_datetime_utc_created" ON g20hackathon_backend.tenant USING btree (core_temporal_datetime_utc_created);
CREATE INDEX "ix_g20hackathon_backend_tnants_core_user_creator_id" ON g20hackathon_backend.tenant USING btree (core_user_creator_id);
CREATE INDEX "ix_g20hackathon_backend_tenants_core_user_deleter_id" ON g20hackathon_backend.tenant USING btree (core_user_deleter_id);
CREATE INDEX "ix_g20hackathon_backend_tenants_core_user_last_modifier_id" ON g20hackathon_backend.tenant USING btree (core_user_last_modifier_id);
CREATE INDEX "ix_g20hackathon_backend_tenants_core_tenancy_name" ON g20hackathon_backend.tenant USING btree (core_tenancy_name);

COMMENT ON TABLE g20hackathon_backend.tenant IS 'Stores tenant information to support multi-tenancy data (where appropriate). A default tenant is always provcore_ided.';

CREATE TABLE g20hackathon_backend.data_set ( 
	core_id uuid DEFAULT gen_random_UUID ()  NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_version TEXT DEFAULT '1.0',
	data_contact TEXT NOT NULL, -- Contact information for inquiries about the dataset.
	data_quality TEXT NOT NULL, -- Information on the accuracy, completeness, and source of the data.
	data_format TEXT NOT NULL, -- Formats in which the data is available.
	data_schema TEXT NOT NULL, -- Describe the data schema, or reference the Json Schema or Frictionless CSV schema. Can be a hyperlink to a relevant schema file.
	data_access_rights TEXT NOT NULL, -- Information on who can access the dataset.
	data_usage_notes TEXT NOT NULL, -- Notes on how the dataset can be used.
	data_related TEXT NOT NULL, -- Links to related datasets for further information or analysis. Could be a list of UUIDs or a textual description, or hyperlinks
	license_name_prefix varchar(12),
	license_name_suffix varchar(12),
	license_name_full varchar(255),
	license_name_short varchar(50),
	license_description_full varchar(8096),
	license_description_short varchar(255),
	license_text text,
	license_standard_license_header varchar(255),
	license_full_terms_url varchar(255),
	CONSTRAINT pk_scenario PRIMARY KEY ( core_id ),
	CONSTRAINT fk_scenario_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_scenario_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_scenario_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id)
 ); 

 COMMENT ON TABLE g20hackathon_backend.data_set IS 'Contains a list of the data sets that are in use in this database, facilitating rigourous data hygeine, governance, and reporting tasks.';


CREATE TABLE g20hackathon_backend.country ( 
	core_id UUID  DEFAULT gen_random_UUID ()  NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	continent text NOT NULL,
	united_nations_global_code NUMERIC NOT NULL, -- Numeric but zero padded
	united_nations_global_name VARCHAR(255) NOT NULL,
	united_nations_region_code NUMERIC NOT NULL, -- Numeric but zero padded
	united_nations_region_name VARCHAR(255) NOT NULL,
	united_nations_sub_region_code NUMERIC, -- Numeric but zero padded
	united_nations_sub_region_name VARCHAR(255),
	united_nations_intermediate_region_code NUMERIC, -- Numeric but zero padded
	united_nations_intermediate_region_name VARCHAR(255),
	united_nations_code_m49 NUMERIC NOT NULL, -- Numeric but zero padded
	united_nations_is_ldc BOOLEAN, -- True if listed on UN Least Developed Countries (LDC)
	united_nations_is_lldc BOOLEAN, -- True if listed on Land Locked Developing Countries (LLDC)
	united_nations_is_sids BOOLEAN, -- True if listed on Small Island Developing States (SIDS)
	iso_code_alpha2 CHAR(2) NOT NULL, -- Alpha-2
	iso_code_alpha3 CHAR(3) NOT NULL, -- Alpha-3
	core_spatial_geometry geometry,
	core_spatial_bbox _float8,
	CONSTRAINT pk_country PRIMARY KEY ( core_id ),
	CONSTRAINT fk_country_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_country_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_country_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_country_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
); 

 COMMENT ON TABLE g20hackathon_backend.country IS 'Contains a list of country ISO codes as described in ISO 3166 standard.';

-- SCHEMA g20hackathon_org
CREATE TABLE g20hackathon_org.industry (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	standard_level smallint NOT NULL,
	standard_structure integer NOT NULL,
	standard_superscript text NOT NULL,
	standard_id uuid NOT NULL,
	standard_code text NOT NULL,
	parent_standard_code text,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_industry_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_industry_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_industry_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_industry_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
	
);

CREATE TABLE g20hackathon_org.organization (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	industry_gics text,
	industry_icb text,
	industry_nace text,
	industry_naics text,
	industry_naics_parent text,
	industry_sic text,
	id_bloomberg_id varchar(12),
	id_bloomberg_ticker varchar(12),
	id_duns text,
	id_figi text,
	id_fitch text,
	id_isin text,
	id_lei varchar(20),
	id_moodys text,
	id_national_company text,
	id_national_tax text,
	id_sp text,
	headquarters_address text NOT NULL,
	offices _text NOT NULL,
	parent_name text NOT NULL,
	schemadotorg jsonb NOT NULL,
	contact_name varchar(255),
	contact_type text,
	contact_email _text,
	contact_fax text,
	contact_telephone _text,
	contact_available_languages _text,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_organization_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_organization_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_organization_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_organization_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)	
);

CREATE TABLE g20hackathon_org.organization_division (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	organization_id uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_organization_division_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_organization_division_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_organization_division_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_organization_division_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)	
);

CREATE INDEX "IX_industry_core_checksum" ON g20hackathon_org.industry USING btree (core_checksum);

CREATE INDEX "IX_industry_core_culture" ON g20hackathon_org.industry USING btree (core_culture);

CREATE INDEX "IX_industry_core_data_set_id" ON g20hackathon_org.industry USING btree (core_data_set_id);

CREATE INDEX "IX_industry_core_id" ON g20hackathon_org.industry USING btree (core_id);

CREATE INDEX "IX_industry_core_user_creator_id" ON g20hackathon_org.industry USING btree (core_user_creator_id);

CREATE INDEX "IX_industry_core_user_deleter_id" ON g20hackathon_org.industry USING btree (core_user_deleter_id);

CREATE INDEX "IX_industry_core_user_last_modifier_id" ON g20hackathon_org.industry USING btree (core_user_last_modifier_id);

CREATE INDEX "IX_organization_core_checksum" ON g20hackathon_org.organization USING btree (core_checksum);

CREATE INDEX "IX_organization_core_culture" ON g20hackathon_org.organization USING btree (core_culture);

CREATE INDEX "IX_organization_core_data_set_id" ON g20hackathon_org.organization USING btree (core_data_set_id);

CREATE INDEX "IX_organization_core_id" ON g20hackathon_org.organization USING btree (core_id);

CREATE INDEX "IX_organization_core_user_creator_id" ON g20hackathon_org.organization USING btree (core_user_creator_id);

CREATE INDEX "IX_organization_core_user_deleter_id" ON g20hackathon_org.organization USING btree (core_user_deleter_id);

CREATE INDEX "IX_organization_core_user_last_modifier_id" ON g20hackathon_org.organization USING btree (core_user_last_modifier_id);

CREATE INDEX "IX_organization_division_core_checksum" ON g20hackathon_org.organization_division USING btree (core_checksum);

CREATE INDEX "IX_organization_division_core_culture" ON g20hackathon_org.organization_division USING btree (core_culture);

CREATE INDEX "IX_organization_division_core_data_set_id" ON g20hackathon_org.organization_division USING btree (core_data_set_id);

CREATE INDEX "IX_organization_division_core_id" ON g20hackathon_org.organization_division USING btree (core_id);

CREATE INDEX "IX_organization_division_core_user_creator_id" ON g20hackathon_org.organization_division USING btree (core_user_creator_id);

CREATE INDEX "IX_organization_division_core_user_deleter_id" ON g20hackathon_org.organization_division USING btree (core_user_deleter_id);

CREATE INDEX "IX_organization_division_core_user_last_modifier_id" ON g20hackathon_org.organization_division USING btree (core_user_last_modifier_id);

CREATE UNIQUE INDEX "PK_industry" ON g20hackathon_org.industry USING btree (core_id);

CREATE UNIQUE INDEX "PK_organization" ON g20hackathon_org.organization USING btree (core_id);

CREATE UNIQUE INDEX "PK_organization_division" ON g20hackathon_org.organization_division USING btree (core_id);



-- SCHEMA g20hackathon_model
CREATE TABLE g20hackathon_model.peril (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_peril_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_peril_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_peril_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_peril_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)	
);

CREATE TABLE g20hackathon_model.hazard (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	frequency text NOT NULL,
	peril_id uuid NOT NULL,
	context_is_chronic_or_acute integer NOT NULL,
	context_is_realized_or_projected integer NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_hazard_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_hazard_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),	
	CONSTRAINT fk_hazard_peril_id FOREIGN KEY ( peril_id ) REFERENCES g20hackathon_model.peril(core_id)	
);
COMMENT ON TABLE g20hackathon_model.hazard IS 'Contains a list of the physical hazards supported by OS-Climate.';

CREATE TABLE g20hackathon_model.hazard_indicator_type (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	category text NOT NULL,
	
	PRIMARY KEY (core_id),
	CONSTRAINT fk_hazard_indicator_type_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_indicator_type_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_indicator_type_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_hazard_indicator_type_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);

CREATE INDEX "IX_hazard_indicator_type_core_checksum" ON g20hackathon_model.hazard_indicator_type USING btree (core_checksum);
CREATE INDEX "IX_hazard_indicator_type_core_culture" ON g20hackathon_model.hazard_indicator_type USING btree (core_culture);
CREATE INDEX "IX_hazard_indicator_type_core_data_set_id" ON g20hackathon_model.hazard_indicator_type USING btree (core_data_set_id);
CREATE INDEX "IX_hazard_indicator_type_core_id" ON g20hackathon_model.hazard_indicator_type USING btree (core_id);
CREATE INDEX "IX_hazard_indicator_type_core_user_creator_id" ON g20hackathon_model.hazard_indicator_type USING btree (core_user_creator_id);
CREATE INDEX "IX_hazard_indicator_type_core_user_deleter_id" ON g20hackathon_model.hazard_indicator_type USING btree (core_user_deleter_id);
CREATE INDEX "IX_hazard_indicator_type_core_user_last_modifier_id" ON g20hackathon_model.hazard_indicator_type USING btree (core_user_last_modifier_id);
CREATE UNIQUE INDEX "PK_hazard_indicator_type" ON g20hackathon_model.hazard_indicator_type USING btree (core_id);


CREATE TABLE g20hackathon_model.hazard_indicator (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	hazard_id uuid NOT NULL,
	hazard_indicator_type_id uuid NOT NULL,
	unit_of_measure text NOT NULL,
	context_is_chronic_or_acute integer NOT NULL,
	context_is_realized_or_projected integer NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_hazard_indicator_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_indicator_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_indicator_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_hazard_indicator_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),	
	CONSTRAINT fk_hazard_indicator_hazard_id FOREIGN KEY ( hazard_id ) REFERENCES g20hackathon_model.hazard(core_id),
	CONSTRAINT fk_hazard_indicator_hazard_indicator_type_id FOREIGN KEY ( hazard_indicator_type_id ) REFERENCES g20hackathon_model.hazard_indicator_type(core_id)		
);
COMMENT ON TABLE g20hackathon_model.hazard_indicator IS 'Contains the set of data indicators that a hazard is present, and which are supported by OS-Climate. An indicator must always relate to one particular hazard.';

CREATE TABLE g20hackathon_model.hazard_model (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	hazard_id uuid NOT NULL,
	model_uri text NOT NULL,
	hazard_indicator_ids _uuid NOT NULL,
	available_scenario_ids _uuid NOT NULL,
	cost_processing_time bigint NOT NULL,
	cost_processing_charges bigint NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_hazard_model_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_model_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_hazard_model_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_hazard_model_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),	
	CONSTRAINT fk_hazard_model_hazard_id FOREIGN KEY ( hazard_id ) REFERENCES g20hackathon_model.hazard(core_id)	
);
COMMENT ON TABLE g20hackathon_model.hazard_model IS 'Contains a list of the hazard models that can be used to assess the presence and risk of a particular hazard, and which are supported by OS-Climate. A hazard model must always relate to one particular hazard but it may support one or multiple indicators.';

CREATE TABLE g20hackathon_model.impact_type (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	frequency integer NOT NULL,
	nature integer NOT NULL,
	financial_accounting_category integer NOT NULL,	
	PRIMARY KEY (core_id),
	CONSTRAINT fk_impact_type_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_impact_type_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_impact_type_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_impact_type_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)	
);
COMMENT ON TABLE g20hackathon_model.impact_type IS 'Contains a list of the potential types of impacts (usually negative) that could result from an asset''s physical risk(s).';

CREATE INDEX "IX_impact_type_core_checksum" ON g20hackathon_model.impact_type USING btree (core_checksum);
CREATE INDEX "IX_impact_type_core_culture" ON g20hackathon_model.impact_type USING btree (core_culture);
CREATE INDEX "IX_impact_type_core_data_set_id" ON g20hackathon_model.impact_type USING btree (core_data_set_id);
CREATE INDEX "IX_impact_type_core_id" ON g20hackathon_model.impact_type USING btree (core_id);
CREATE INDEX "IX_impact_type_core_user_creator_id" ON g20hackathon_model.impact_type USING btree (core_user_creator_id);
CREATE INDEX "IX_impact_type_core_user_deleter_id" ON g20hackathon_model.impact_type USING btree (core_user_deleter_id);
CREATE INDEX "IX_impact_type_core_user_last_modifier_id" ON g20hackathon_model.impact_type USING btree (core_user_last_modifier_id);
CREATE UNIQUE INDEX "PK_impact_type" ON g20hackathon_model.impact_type USING btree (core_id);


CREATE TABLE g20hackathon_model.scenario (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	temporal_historic_year_first smallint,
	temporal_historic_year_last smallint,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_scenario_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_scenario_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_scenario_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_scenario_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)	
);
COMMENT ON TABLE g20hackathon_model.scenario IS 'Contains a list of the United Nations Intergovernmental Panel on Climate Change (IPCC)-defined climate scenarios (SSPs and RCPs).';

CREATE TABLE g20hackathon_model.vulnerability_model (
	core_id uuid DEFAULT gen_random_UUID () NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	hazard_model_ids _uuid NOT NULL,
	model_uri text NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_vulnerability_model_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_vulnerability_model_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_vulnerability_model_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_vulnerability_model_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)	
);
COMMENT ON TABLE g20hackathon_model.vulnerability_model IS 'Contains a list of the vulnerability models that can be used to assess the physical climate risk to assets, and which are supported by OS-Climate. A vulnerability model must support one or more hazard models (effectively, one or more hazards can be assessed).';


CREATE INDEX "IX_hazard_core_checksum" ON g20hackathon_model.hazard USING btree (core_checksum);

CREATE INDEX "IX_hazard_core_culture" ON g20hackathon_model.hazard USING btree (core_culture);

CREATE INDEX "IX_hazard_core_data_set_id" ON g20hackathon_model.hazard USING btree (core_data_set_id);

CREATE INDEX "IX_hazard_core_id" ON g20hackathon_model.hazard USING btree (core_id);

CREATE INDEX "IX_hazard_core_user_creator_id" ON g20hackathon_model.hazard USING btree (core_user_creator_id);

CREATE INDEX "IX_hazard_core_user_deleter_id" ON g20hackathon_model.hazard USING btree (core_user_deleter_id);

CREATE INDEX "IX_hazard_core_user_last_modifier_id" ON g20hackathon_model.hazard USING btree (core_user_last_modifier_id);

CREATE INDEX "IX_hazard_indicator_core_checksum" ON g20hackathon_model.hazard_indicator USING btree (core_checksum);

CREATE INDEX "IX_hazard_indicator_core_culture" ON g20hackathon_model.hazard_indicator USING btree (core_culture);

CREATE INDEX "IX_hazard_indicator_core_data_set_id" ON g20hackathon_model.hazard_indicator USING btree (core_data_set_id);

CREATE INDEX "IX_hazard_indicator_core_id" ON g20hackathon_model.hazard_indicator USING btree (core_id);

CREATE INDEX "IX_hazard_indicator_core_user_creator_id" ON g20hackathon_model.hazard_indicator USING btree (core_user_creator_id);

CREATE INDEX "IX_hazard_indicator_core_user_deleter_id" ON g20hackathon_model.hazard_indicator USING btree (core_user_deleter_id);

CREATE INDEX "IX_hazard_indicator_core_user_last_modifier_id" ON g20hackathon_model.hazard_indicator USING btree (core_user_last_modifier_id);

CREATE INDEX "IX_hazard_indicator_hazard_id" ON g20hackathon_model.hazard_indicator USING btree (hazard_id);

CREATE INDEX "IX_hazard_model_core_checksum" ON g20hackathon_model.hazard_model USING btree (core_checksum);

CREATE INDEX "IX_hazard_model_core_culture" ON g20hackathon_model.hazard_model USING btree (core_culture);

CREATE INDEX "IX_hazard_model_core_data_set_id" ON g20hackathon_model.hazard_model USING btree (core_data_set_id);

CREATE INDEX "IX_hazard_model_core_id" ON g20hackathon_model.hazard_model USING btree (core_id);

CREATE INDEX "IX_hazard_model_core_user_creator_id" ON g20hackathon_model.hazard_model USING btree (core_user_creator_id);

CREATE INDEX "IX_hazard_model_core_user_deleter_id" ON g20hackathon_model.hazard_model USING btree (core_user_deleter_id);

CREATE INDEX "IX_hazard_model_core_user_last_modifier_id" ON g20hackathon_model.hazard_model USING btree (core_user_last_modifier_id);

CREATE INDEX "IX_hazard_model_hazard_id" ON g20hackathon_model.hazard_model USING btree (hazard_id);

CREATE INDEX "IX_hazard_peril_id" ON g20hackathon_model.hazard USING btree (peril_id);

CREATE INDEX "IX_peril_core_checksum" ON g20hackathon_model.peril USING btree (core_checksum);

CREATE INDEX "IX_peril_core_culture" ON g20hackathon_model.peril USING btree (core_culture);

CREATE INDEX "IX_peril_core_data_set_id" ON g20hackathon_model.peril USING btree (core_data_set_id);

CREATE INDEX "IX_peril_core_id" ON g20hackathon_model.peril USING btree (core_id);

CREATE INDEX "IX_peril_core_user_creator_id" ON g20hackathon_model.peril USING btree (core_user_creator_id);

CREATE INDEX "IX_peril_core_user_deleter_id" ON g20hackathon_model.peril USING btree (core_user_deleter_id);

CREATE INDEX "IX_peril_core_user_last_modifier_id" ON g20hackathon_model.peril USING btree (core_user_last_modifier_id);

CREATE INDEX "IX_scenario_core_checksum" ON g20hackathon_model.scenario USING btree (core_checksum);

CREATE INDEX "IX_scenario_core_culture" ON g20hackathon_model.scenario USING btree (core_culture);

CREATE INDEX "IX_scenario_core_data_set_id" ON g20hackathon_model.scenario USING btree (core_data_set_id);

CREATE INDEX "IX_scenario_core_id" ON g20hackathon_model.scenario USING btree (core_id);

CREATE INDEX "IX_scenario_core_user_creator_id" ON g20hackathon_model.scenario USING btree (core_user_creator_id);

CREATE INDEX "IX_scenario_core_user_deleter_id" ON g20hackathon_model.scenario USING btree (core_user_deleter_id);

CREATE INDEX "IX_scenario_core_user_last_modifier_id" ON g20hackathon_model.scenario USING btree (core_user_last_modifier_id);

CREATE INDEX "IX_vulnerability_model_core_checksum" ON g20hackathon_model.vulnerability_model USING btree (core_checksum);

CREATE INDEX "IX_vulnerability_model_core_culture" ON g20hackathon_model.vulnerability_model USING btree (core_culture);

CREATE INDEX "IX_vulnerability_model_core_data_set_id" ON g20hackathon_model.vulnerability_model USING btree (core_data_set_id);

CREATE INDEX "IX_vulnerability_model_core_id" ON g20hackathon_model.vulnerability_model USING btree (core_id);

CREATE INDEX "IX_vulnerability_model_core_user_creator_id" ON g20hackathon_model.vulnerability_model USING btree (core_user_creator_id);

CREATE INDEX "IX_vulnerability_model_core_user_deleter_id" ON g20hackathon_model.vulnerability_model USING btree (core_user_deleter_id);

CREATE INDEX "IX_vulnerability_model_core_user_last_modifier_id" ON g20hackathon_model.vulnerability_model USING btree (core_user_last_modifier_id);

CREATE UNIQUE INDEX "PK_hazard" ON g20hackathon_model.hazard USING btree (core_id);

CREATE UNIQUE INDEX "PK_hazard_indicator" ON g20hackathon_model.hazard_indicator USING btree (core_id);

CREATE UNIQUE INDEX "PK_hazard_model" ON g20hackathon_model.hazard_model USING btree (core_id);

CREATE UNIQUE INDEX "PK_peril" ON g20hackathon_model.peril USING btree (core_id);

CREATE UNIQUE INDEX "PK_scenario" ON g20hackathon_model.scenario USING btree (core_id);

CREATE UNIQUE INDEX "PK_vulnerability_model" ON g20hackathon_model.vulnerability_model USING btree (core_id);

-- -- CREATE SCHEMA g20hackathon_structure
CREATE TABLE g20hackathon_structure.structure (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	country_id uuid,
	core_spatial_location_address text,
	core_spatial_location_name text,
	core_spatial_bbox _float8,
	core_spatial_elevation float8,
	core_spatial_height_minimum float8,
	core_spatial_height_maximum float8,
	core_spatial_height_unit_of_measure varchar(64),
	core_spatial_height_confidence float8,
	core_spatial_elevation_minimum float8,
	core_spatial_elevation_maximum float8,
	core_spatial_elevation_unit_of_measure varchar(64),
	core_spatial_elevation_confidence float8,
	core_spatial_h3_index integer,
	core_spatial_h3_resolution integer,
	core_spatial_overture_gers_id uuid,
	core_spatial_overture_features jsonb,
	area_minimum float8,
	area_maximum float8,
	area_unit_of_measure varchar(64),
	area_confidence float8,
	number_stories integer,
	year_built smallint,
	year_upgraded smallint,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_structure_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_structure_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);
COMMENT ON TABLE g20hackathon_structure.structure IS 'A physical structure (building, shed, bridge, etc.) which may or may not be habitable, and may be vulnerable to physical risks.';


CREATE TABLE g20hackathon_structure.class_land_cover (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_land_cover_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_land_cover_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_land_cover_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_land_cover_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);
COMMENT ON TABLE g20hackathon_structure.class_land_cover IS 'The land cover classification for a specific asset location. This includes information about the type of vegetation, urban development, and other land use characteristics that may influence the asset''s vulnerability to physical risks.';
CREATE TABLE g20hackathon_structure.class_land_use (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_land_use_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_land_use_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_land_use_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_land_use_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);

COMMENT ON TABLE g20hackathon_structure.class_land_use IS 'The land use classification for a specific asset location. This includes information about how humans use the area surrounding the asset that may influence its vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.class_slope (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_slope_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_slope_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_slope_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_slope_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);
COMMENT ON TABLE g20hackathon_structure.class_slope IS 'The slope classification for a specific asset location. This includes information about the steepness and stability of the terrain, which may influence the asset''s vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.class_impervious_ratio (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_impervious_ratio_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_impervious_ratio_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_impervious_ratio_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_impervious_ratio_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);
COMMENT ON TABLE g20hackathon_structure.class_impervious_ratio IS 'The impervious surface ratio classification for a specific asset location. This includes information about the extent of impervious surfaces, which may influence the asset''s vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.class_tree_canopy_ratio (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_tree_canopy_ratio_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_tree_canopy_ratio_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_tree_canopy_ratio_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_tree_canopy_ratio_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);

COMMENT ON TABLE g20hackathon_structure.class_tree_canopy_ratio IS 'The tree canopy classification for a specific asset location. This includes information about the extent of tree cover, which may influence the asset''s vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.class_vegetation (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_vegetation_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_vegetation_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_vegetation_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_vegetation_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);

COMMENT ON TABLE g20hackathon_structure.class_vegetation IS 'The type of vegetation present for a specific asset location. This includes information about the vegetative species surrounding the asset that may influence its vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.class_water_distance (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_water_distance_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_water_distance_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_water_distance_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_water_distance_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);

COMMENT ON TABLE g20hackathon_structure.class_water_distance IS 'The water distance classification for a specific asset location. This includes information about the proximity to water bodies, which may influence the asset''s vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.class_defensible_space (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_class_defensible_space_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_defensible_space_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_class_defensible_space_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_class_defensible_space_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);

COMMENT ON TABLE g20hackathon_structure.class_defensible_space IS 'The defensible space classification for a specific asset location. This includes information about the area surrounding the asset that may influence its vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.perimeter_ring (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	metres_inner numeric(8,2) NOT NULL,     -- e.g., 0.00
	metres_outer numeric(8,2) NOT NULL,     -- e.g., 5.00
	CHECK (metres_inner >= 0 AND metres_outer > metres_inner),
	PRIMARY KEY (core_id),
	CONSTRAINT fk_perimeter_ring_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_perimeter_ring_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_perimeter_ring_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_perimeter_ring_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);
COMMENT ON TABLE g20hackathon_structure.perimeter_ring IS 'The perimeter ring for a specific asset location. This includes information about the area surrounding the asset that may influence its vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.construction_type (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	openexposuredata_oed_code smallint NOT NULL,
	openexposuredata_cede_code varchar(50) NOT NULL,
	openexposuredata_code_range varchar(50) NOT NULL,
	openexposuredata_broad_category varchar(50) NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_construction_type_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_construction_type_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_construction_type_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_construction_type_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);
COMMENT ON TABLE g20hackathon_structure.construction_type IS 'The type of construction method or material an asset is made of, helpful for determining vulnerability or exposure.';

CREATE INDEX "IX_construction_type_core_checksum" ON g20hackathon_structure.construction_type USING btree (core_checksum);
CREATE INDEX "IX_construction_type_core_culture" ON g20hackathon_structure.construction_type USING btree (core_culture);
CREATE INDEX "IX_construction_type_core_data_set_id" ON g20hackathon_structure.construction_type USING btree (core_data_set_id);
CREATE INDEX "IX_construction_type_core_id" ON g20hackathon_structure.construction_type USING btree (core_id);
CREATE INDEX "IX_construction_type_core_user_creator_id" ON g20hackathon_structure.construction_type USING btree (core_user_creator_id);
CREATE INDEX "IX_construction_type_core_user_deleter_id" ON g20hackathon_structure.construction_type USING btree (core_user_deleter_id);
CREATE INDEX "IX_construction_type_core_user_last_modifier_id" ON g20hackathon_structure.construction_type USING btree (core_user_last_modifier_id);
CREATE UNIQUE INDEX "PK_construction_type" ON g20hackathon_structure.construction_type USING btree (core_id);


CREATE TABLE g20hackathon_structure.occupancy_type (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	openexposuredata_oed_code smallint NOT NULL,
	openexposuredata_cede_code varchar(50) NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_occupancy_type_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_occupancy_type_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_occupancy_type_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_occupancy_type_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id) 	
);

COMMENT ON TABLE g20hackathon_structure.occupancy_type IS 'The Open Exposure Data Occupancy Code information.';

CREATE INDEX "IX_occupancy_type_type_core_checksum" ON g20hackathon_structure.occupancy_type USING btree (core_checksum);
CREATE INDEX "IX_occupancy_type_type_core_culture" ON g20hackathon_structure.occupancy_type USING btree (core_culture);
CREATE INDEX "IX_occupancy_type_type_core_data_set_id" ON g20hackathon_structure.occupancy_type USING btree (core_data_set_id);
CREATE INDEX "IX_occupancy_type_type_core_id" ON g20hackathon_structure.occupancy_type USING btree (core_id);
CREATE INDEX "IX_occupancy_type_type_core_user_creator_id" ON g20hackathon_structure.occupancy_type USING btree (core_user_creator_id);
CREATE INDEX "IX_occupancy_type_type_core_user_deleter_id" ON g20hackathon_structure.occupancy_type USING btree (core_user_deleter_id);
CREATE INDEX "IX_occupancy_type_type_core_user_last_modifier_id" ON g20hackathon_structure.occupancy_type USING btree (core_user_last_modifier_id);
CREATE UNIQUE INDEX "PK_occupancy_type" ON g20hackathon_structure.occupancy_type USING btree (core_id);


CREATE TABLE g20hackathon_structure.structure_component (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_structure_component_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_component_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_component_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_structure_component_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id)
);
COMMENT ON TABLE g20hackathon_structure.structure_component IS 'The type of internal components (HVAC, elevator, fire, electrical, etc) that an asset contains, helpful for determining vulnerability or exposure.';

CREATE INDEX "IX_structure_component_core_checksum" ON g20hackathon_structure.structure_component USING btree (core_checksum);
CREATE INDEX "IX_structure_component_core_culture" ON g20hackathon_structure.structure_component USING btree (core_culture);
CREATE INDEX "IX_structure_component_core_data_set_id" ON g20hackathon_structure.structure_component USING btree (core_data_set_id);
CREATE INDEX "IX_structure_component_core_id" ON g20hackathon_structure.structure_component USING btree (core_id);
CREATE INDEX "IX_structure_component_core_user_creator_id" ON g20hackathon_structure.structure_component USING btree (core_user_creator_id);
CREATE INDEX "IX_structure_component_core_user_deleter_id" ON g20hackathon_structure.structure_component USING btree (core_user_deleter_id);
CREATE INDEX "IX_structure_component_core_user_last_modifier_id" ON g20hackathon_structure.structure_component USING btree (core_user_last_modifier_id);
CREATE UNIQUE INDEX "PK_structure_component" ON g20hackathon_structure.structure_component USING btree (core_id);

CREATE TABLE g20hackathon_structure.structure_surrounding_ring (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,	
	structure_id uuid NOT NULL,
	perimeter_ring_id uuid NOT NULL,
	defensible_space_class_id uuid,
	impervious_ratio_class_id uuid,
	impervious_ratio numeric(5,2),
	land_cover_primary_class_id uuid,
	land_use_primary_class_id uuid,
	slope_class_id uuid,
	slope_degrees numeric(5,2),
	tree_canopy_ratio_class_id uuid,
	tree_canopy_ratio numeric(5,2),
	vegetation_primary_class_id uuid,
	water_distance_class_id uuid,
	water_distance_metres numeric(5,2),
	PRIMARY KEY (core_id),
	CONSTRAINT fk_structure_surrounding_ring_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_surrounding_ring_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_surrounding_ring_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_structure_id FOREIGN KEY ( structure_id ) REFERENCES g20hackathon_structure.structure(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_perimeter_ring_id FOREIGN KEY ( perimeter_ring_id ) REFERENCES g20hackathon_structure.perimeter_ring(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_defensible_space_id FOREIGN KEY ( defensible_space_class_id ) REFERENCES g20hackathon_structure.class_defensible_space(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_impervious_ratio_id FOREIGN KEY ( impervious_ratio_class_id ) REFERENCES g20hackathon_structure.class_impervious_ratio(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_class_primary_land_cover_id_id FOREIGN KEY ( land_cover_primary_class_id ) REFERENCES g20hackathon_structure.class_land_cover(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_primary_land_use_id FOREIGN KEY ( land_use_primary_class_id ) REFERENCES g20hackathon_structure.class_land_use(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_slope_id FOREIGN KEY ( slope_class_id ) REFERENCES g20hackathon_structure.class_slope(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_tree_canopy_ratio_id FOREIGN KEY ( tree_canopy_ratio_class_id ) REFERENCES g20hackathon_structure.class_tree_canopy_ratio(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_vegetation_id FOREIGN KEY ( vegetation_primary_class_id ) REFERENCES g20hackathon_structure.class_vegetation(core_id),
 	CONSTRAINT fk_structure_surrounding_ring_class_water_distance_id FOREIGN KEY ( water_distance_class_id ) REFERENCES g20hackathon_structure.class_water_distance(core_id)
);
COMMENT ON TABLE g20hackathon_structure.structure_surrounding_ring IS 'Ring information for a specific structure location. This includes information about the area surrounding the structure, within a certain inner and outer ring, that may influence its vulnerability to physical risks.';

CREATE TABLE g20hackathon_structure.bridge_structure_structure_component (
	structure_id uuid NOT NULL,
	structure_component_id uuid NOT NULL,
	details_json jsonb,
	PRIMARY KEY (structure_id,structure_component_id),
	CONSTRAINT fk_bridge_structure_structure_component_structure_id FOREIGN KEY ( structure_id ) REFERENCES g20hackathon_structure.structure(core_id),	
	CONSTRAINT fk_bridge_structure_structure_component_structure_component_id FOREIGN KEY ( structure_component_id ) REFERENCES g20hackathon_structure.structure_component(core_id)
);
COMMENT ON TABLE g20hackathon_structure.bridge_structure_structure_component IS 'Many-to-many bridge between a structure and its internal components (HVAC, elevator, fire, electrical, etc) that a structure may contain, helpful for determining vulnerability or exposure.';

CREATE TABLE g20hackathon_structure.structure_foundation_construction (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	structure_id uuid NOT NULL,
	primary_construction_type_id uuid NOT NULL,
	secondary_construction_type_id uuid,
	details_json jsonb,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_structure_foundation_construction_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_foundation_construction_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_foundation_construction_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_structure_foundation_construction_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),
	CONSTRAINT fk_structure_foundation_construction_structure_id FOREIGN KEY ( structure_id ) REFERENCES g20hackathon_structure.structure(core_id),
	CONSTRAINT fk_structure_foundation_construction_primary_construction_type_id FOREIGN KEY ( primary_construction_type_id ) REFERENCES g20hackathon_structure.construction_type(core_id),
	CONSTRAINT fk_structure_foundation_construction_secondary_construction_type_id FOREIGN KEY ( secondary_construction_type_id ) REFERENCES g20hackathon_structure.construction_type(core_id)
);
COMMENT ON TABLE g20hackathon_structure.structure_foundation_construction IS 'Helps define variables related to the type of construction of an asset''s foundation, such as its material or manufacturing method, which can help establish potential vulnerability or exposure.';

CREATE INDEX "IX_structure_foundation_construction_structure_id" ON g20hackathon_structure.structure_foundation_construction USING btree (structure_id);
CREATE INDEX "IX_structure_foundation_construction_core_checksum" ON g20hackathon_structure.structure_foundation_construction USING btree (core_checksum);
CREATE INDEX "IX_structure_foundation_construction_core_culture" ON g20hackathon_structure.structure_foundation_construction USING btree (core_culture);
CREATE INDEX "IX_structure_foundation_construction_core_data_set_id" ON g20hackathon_structure.structure_foundation_construction USING btree (core_data_set_id);
CREATE INDEX "IX_structure_foundation_construction_core_id" ON g20hackathon_structure.structure_foundation_construction USING btree (core_id);
CREATE INDEX "IX_structure_foundation_construction_core_user_creator_id" ON g20hackathon_structure.structure_foundation_construction USING btree (core_user_creator_id);
CREATE INDEX "IX_structure_foundation_construction_core_user_deleter_id" ON g20hackathon_structure.structure_foundation_construction USING btree (core_user_deleter_id);
CREATE INDEX "IX_structure_foundation_construction_core_user_last_modifier_id" ON g20hackathon_structure.structure_foundation_construction USING btree (core_user_last_modifier_id);
CREATE INDEX "IX_structure_foundation_construction_primary_construction_type_id" ON g20hackathon_structure.structure_foundation_construction USING btree (primary_construction_type_id);
CREATE INDEX "IX_structure_foundation_construction_secondary_construction_type_id" ON g20hackathon_structure.structure_foundation_construction USING btree (secondary_construction_type_id);
CREATE UNIQUE INDEX "PK_structure_foundation_construction" ON g20hackathon_structure.structure_foundation_construction USING btree (core_id);


CREATE TABLE g20hackathon_structure.structure_frame_construction (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	structure_id uuid NOT NULL,
	primary_construction_type_id uuid NOT NULL,
	secondary_construction_type_id uuid,
	details_json jsonb,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_structure_frame_construction_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_frame_construction_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_frame_construction_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_structure_frame_construction_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),
	CONSTRAINT fk_structure_frame_construction_structure_id FOREIGN KEY ( structure_id ) REFERENCES g20hackathon_structure.structure(core_id),
	CONSTRAINT fk_structure_frame_construction_primary_construction_type_id FOREIGN KEY ( primary_construction_type_id ) REFERENCES g20hackathon_structure.construction_type(core_id),
	CONSTRAINT fk_structure_frame_construction_secondary_construction_type_id FOREIGN KEY ( secondary_construction_type_id ) REFERENCES g20hackathon_structure.construction_type(core_id)
);
COMMENT ON TABLE g20hackathon_structure.structure_frame_construction IS 'Helps define variables related to the type of construction of an asset''s frame, such as its material or manufacturing method, which can help establish potential vulnerability or exposure.';

CREATE INDEX "IX_structure_frame_construction_structure_id" ON g20hackathon_structure.structure_frame_construction USING btree (structure_id);
CREATE INDEX "IX_structure_frame_construction_core_checksum" ON g20hackathon_structure.structure_frame_construction USING btree (core_checksum);
CREATE INDEX "IX_structure_frame_construction_core_culture" ON g20hackathon_structure.structure_frame_construction USING btree (core_culture);
CREATE INDEX "IX_structure_frame_construction_core_data_set_id" ON g20hackathon_structure.structure_frame_construction USING btree (core_data_set_id);
CREATE INDEX "IX_structure_frame_construction_core_id" ON g20hackathon_structure.structure_frame_construction USING btree (core_id);
CREATE INDEX "IX_structure_frame_construction_core_user_creator_id" ON g20hackathon_structure.structure_frame_construction USING btree (core_user_creator_id);
CREATE INDEX "IX_structure_frame_construction_core_user_deleter_id" ON g20hackathon_structure.structure_frame_construction USING btree (core_user_deleter_id);
CREATE INDEX "IX_structure_frame_construction_core_user_last_modifier_id" ON g20hackathon_structure.structure_frame_construction USING btree (core_user_last_modifier_id);
CREATE INDEX "IX_structure_frame_construction_primary_construction_type_id" ON g20hackathon_structure.structure_frame_construction USING btree (primary_construction_type_id);
CREATE INDEX "IX_structure_frame_construction_secondary_construction_type_id" ON g20hackathon_structure.structure_frame_construction USING btree (secondary_construction_type_id);
CREATE UNIQUE INDEX "PK_structure_frame_construction" ON g20hackathon_structure.structure_frame_construction USING btree (core_id);

CREATE TABLE g20hackathon_structure.structure_roof_construction (
	core_id uuid NOT NULL,
	core_name_short varchar(50),
	core_name_full varchar(255),
	core_name_suffix varchar(12),
	core_name_prefix varchar(12),
	core_description_short varchar(255),
	core_description_full varchar(8096),
	core_tags jsonb,
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5),
	core_checksum varchar(64),
	core_seq_num integer,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
	structure_id uuid NOT NULL,
	primary_construction_type_id uuid NOT NULL,
	secondary_construction_type_id uuid,
	details_json jsonb,
	roof_year_built smallint,
	oed_roof_equipment text,
	oed_roof_maintenance text,
	oed_roof_attached_structures text,
	oed_roof_deck smallint,
	oed_roof_pitch_degrees smallint,
	oed_roof_anchorage smallint,
	oed_roof_deck_attachment smallint,
	oed_roof_cover_attachment smallint,
	PRIMARY KEY (core_id),
	CONSTRAINT fk_structure_roof_construction_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_roof_construction_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_structure_roof_construction_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
 	CONSTRAINT fk_structure_roof_construction_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),
	CONSTRAINT fk_structure_roof_construction_structure_id FOREIGN KEY ( structure_id ) REFERENCES g20hackathon_structure.structure(core_id),
	CONSTRAINT fk_structure_roof_construction_primary_construction_type_id FOREIGN KEY ( primary_construction_type_id ) REFERENCES g20hackathon_structure.construction_type(core_id),
	CONSTRAINT fk_structure_roof_construction_secondary_construction_type_id FOREIGN KEY ( secondary_construction_type_id ) REFERENCES g20hackathon_structure.construction_type(core_id)
);
COMMENT ON TABLE g20hackathon_structure.structure_roof_construction IS 'Helps define variables related to the type of construction of an asset''s roof, such as its material or manufacturing method, which can help establish potential vulnerability or exposure.';

CREATE INDEX "IX_structure_roof_construction_structure_id" ON g20hackathon_structure.structure_roof_construction USING btree (structure_id);
CREATE INDEX "IX_structure_roof_construction_core_checksum" ON g20hackathon_structure.structure_roof_construction USING btree (core_checksum);
CREATE INDEX "IX_structure_roof_construction_core_culture" ON g20hackathon_structure.structure_roof_construction USING btree (core_culture);
CREATE INDEX "IX_structure_roof_construction_core_data_set_id" ON g20hackathon_structure.structure_roof_construction USING btree (core_data_set_id);
CREATE INDEX "IX_structure_roof_construction_core_id" ON g20hackathon_structure.structure_roof_construction USING btree (core_id);
CREATE INDEX "IX_structure_roof_construction_core_user_creator_id" ON g20hackathon_structure.structure_roof_construction USING btree (core_user_creator_id);
CREATE INDEX "IX_structure_roof_construction_core_user_deleter_id" ON g20hackathon_structure.structure_roof_construction USING btree (core_user_deleter_id);
CREATE INDEX "IX_structure_roof_construction_core_user_last_modifier_id" ON g20hackathon_structure.structure_roof_construction USING btree (core_user_last_modifier_id);
CREATE INDEX "IX_structure_roof_construction_primary_construction_type_id" ON g20hackathon_structure.structure_roof_construction USING btree (primary_construction_type_id);
CREATE INDEX "IX_structure_roof_construction_secondary_construction_type_id" ON g20hackathon_structure.structure_roof_construction USING btree (secondary_construction_type_id);
CREATE UNIQUE INDEX "PK_structure_roof_construction" ON g20hackathon_structure.structure_roof_construction USING btree (core_id);



CREATE TABLE g20hackathon_model.exposure_function ( 
	core_id uuid DEFAULT gen_random_UUID ()  NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_tenant_id bigint,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	CONSTRAINT pk_exposure_function PRIMARY KEY ( core_id ),
	CONSTRAINT fk_exposure_function_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),
	CONSTRAINT fk_exposure_function_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_exposure_function_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_exposure_function_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_exposure_function_core_tenant_id FOREIGN KEY ( core_tenant_id ) REFERENCES g20hackathon_backend.tenant(core_id)
 );
 COMMENT ON TABLE g20hackathon_model.exposure_function IS 'The model used to determine whether a particular asset is exposed to a particular hazard indicator.';


CREATE TABLE g20hackathon_model.vulnerability_type ( 
	core_id uuid DEFAULT gen_random_UUID ()  NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_tenant_id bigint,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
    accounting_category VARCHAR(255),
	CONSTRAINT pk_vulnerability_type PRIMARY KEY ( core_id ),
	CONSTRAINT fk_vulnerability_type_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),
	CONSTRAINT fk_vulnerability_type_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_vulnerability_type_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_vulnerability_type_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id)
 ); 
COMMENT ON TABLE g20hackathon_model.vulnerability_type IS 'A lookup table to classify and constrain types of damage/disruption that could occur to an asset due to its vulnerability to a hazard.';

CREATE TABLE g20hackathon_model.vulnerability_function ( 
	core_id uuid DEFAULT gen_random_UUID ()  NOT NULL,
	core_description_full varchar(8096) NOT NULL,
	core_description_short varchar(255),
	core_name_full varchar(255),
	core_name_prefix varchar(12),
	core_name_short varchar(50),
	core_name_suffix varchar(12),
	core_temporal_datetime_utc_created timestamptz NOT NULL,
	core_tenant_id bigint,
	core_user_creator_id bigint,
	core_temporal_datetime_utc_last_modified timestamptz,
	core_user_last_modifier_id bigint,
	core_is_deleted bool NOT NULL,
	core_user_deleter_id bigint,
	core_temporal_datetime_utc_deleted timestamptz,
	core_culture varchar(5) NOT NULL,
	core_checksum varchar(64),
	core_seq_num integer,
	core_tags jsonb,
	core_translated_from_id uuid,
	core_is_active bool NOT NULL,
	core_data_set_id uuid NOT NULL,
	CONSTRAINT pk_vulnerability_function PRIMARY KEY ( core_id ),
	CONSTRAINT fk_vulnerability_function_core_data_set_id FOREIGN KEY ( core_data_set_id ) REFERENCES g20hackathon_backend.data_set(core_id),
	CONSTRAINT fk_vulnerability_core_user_creator_id FOREIGN KEY ( core_user_creator_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_vulnerability_core_user_last_modifier_id FOREIGN KEY ( core_user_last_modifier_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_vulnerability_core_user_deleter_id FOREIGN KEY ( core_user_deleter_id ) REFERENCES g20hackathon_backend.user(core_id),
	CONSTRAINT fk_vulnerability_core_tenant_id FOREIGN KEY ( core_tenant_id ) REFERENCES g20hackathon_backend.tenant(core_id)
 );
COMMENT ON TABLE g20hackathon_model.vulnerability_function IS 'The model used to determine the degree by which a particular asset is vulnerable to a particular hazard indicator. If an asset is vulnerable to a peril, it must necessarily be exposed to it (see exposure_function).';



-- SETUP PERMISSIONS FOR A READER SQL SERVICE ACCOUNT (CREATE THAT USING A DATABASE TOOL)
--GRANT USAGE ON SCHEMA "g20hackathon_backend" TO physrisk_reader_service;
--GRANT SELECT ON ALL TABLES IN SCHEMA "g20hackathon_backend" TO physrisk_reader_service;
--GRANT USAGE ON SCHEMA "g20hackathon_org" TO physrisk_reader_service;
--GRANT SELECT ON ALL TABLES IN SCHEMA "g20hackathon_org" TO physrisk_reader_service;
--GRANT USAGE ON SCHEMA "g20hackathon_model" TO physrisk_reader_service;
--GRANT SELECT ON ALL TABLES IN SCHEMA "g20hackathon_model" TO physrisk_reader_service;
--GRANT USAGE ON SCHEMA "g20hackathon_assets" TO physrisk_reader_service;
--GRANT SELECT ON ALL TABLES IN SCHEMA "g20hackathon_assets" TO physrisk_reader_service;
--GRANT USAGE ON SCHEMA "g20hackathon_structure" TO physrisk_reader_service;
--GRANT SELECT ON ALL TABLES IN SCHEMA "g20hackathon_structure" TO physrisk_reader_service;
--GRANT USAGE ON SCHEMA "g20hackathon_analysis" TO physrisk_reader_service;
--GRANT SELECT ON ALL TABLES IN SCHEMA "g20hackathon_analysis" TO physrisk_reader_service;
--GRANT USAGE ON SCHEMA "g20hackathon_analysis" TO physrisk_reader_service;
--GRANT SELECT ON ALL TABLES IN SCHEMA "g20hackathon_analysis" TO physrisk_reader_service;

-- SETUP PERMISSIONS FOR A READER/WRITER SQL SERVICE ACCOUNT (CREATE THAT USING A DATABASE TOOL)
--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "g20hackathon_backend" TO physrisk_readerwriter_service;
--GRANT ALL ON ALL TABLES IN SCHEMA "g20hackathon_backend" TO physrisk_readerwriter_service;
--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "g20hackathon_org" TO physrisk_readerwriter_service;
--GRANT ALL ON ALL TABLES IN SCHEMA "g20hackathon_org" TO physrisk_readerwriter_service;
--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "g20hackathon_model" TO physrisk_readerwriter_service;
--GRANT ALL ON ALL TABLES IN SCHEMA "g20hackathon_model" TO physrisk_readerwriter_service;
--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "g20hackathon_assets" TO physrisk_readerwriter_service;
--GRANT ALL ON ALL TABLES IN SCHEMA "g20hackathon_assets" TO physrisk_readerwriter_service;
--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "g20hackathon_structure" TO physrisk_readerwriter_service;
--GRANT ALL ON ALL TABLES IN SCHEMA "g20hackathon_structure" TO physrisk_readerwriter_service;
--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "g20hackathon_analysis" TO physrisk_readerwriter_service;
--GRANT ALL ON ALL TABLES IN SCHEMA "g20hackathon_analysis" TO physrisk_readerwriter_service;
--GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "g20hackathon_analysis" TO physrisk_readerwriter_service;
--GRANT ALL ON ALL TABLES IN SCHEMA "g20hackathon_analysis" TO physrisk_readerwriter_service;
