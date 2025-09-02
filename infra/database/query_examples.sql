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

-- EXAMPLE QUERIES
-- VIEW SCENARIOS IN DIFFERENT LANGUAGES
SELECT * FROM g20hackathon_model.scenario WHERE core_culture='en';
SELECT * FROM g20hackathon_model.scenario WHERE core_culture='fr';
SELECT * FROM g20hackathon_model.scenario WHERE core_culture='es';

SELECT a.core_name_short as "English core_name_short",  b.core_culture as "Translated core_culture",  b.core_name_short as "Translated core_name_short", b.core_description_full as "Translated Description", b.core_tags as "Translated core_tags" FROM g20hackathon_model.scenario a 
INNER JOIN g20hackathon_model.scenario b ON a.core_id = b.core_translated_from_id
WHERE b.core_culture='es'  ;


-- QUERY BY core_tags EXAMPLE: FIND SCENARIOS WITH CERTAIN core_tags
SELECT a.core_name_full,  a.core_description_full, a.core_tags FROM g20hackathon_model.scenario a
WHERE a.core_tags -> 'key1'='"value1"' OR a.core_tags -> 'key2'='"value4"'  
;

-- VIEW RIVERINE INUNDATION HAZARD INDICATORS
SELECT	*
FROM
	g20hackathon_model.hazard haz INNER JOIN g20hackathon_model.hazard_indicator hi ON hi.hazard_id = haz.core_id
WHERE haz.core_name_short = 'Riverine Inundation' -- more likely written as WHERE haz.core_id = '63ed7943-c4c4-43ea-abd2-86bb1997a094'
;

-- VIEW COASTAL INUNDATION HAZARD INDICATORS
SELECT	*
FROM
	 g20hackathon_model.hazard haz INNER JOIN g20hackathon_model.hazard_indicator hi ON hi.hazard_id = haz.core_id
WHERE haz.core_id = '28a095cd-4cde-40a1-90d9-cbb0ca673c06'
;

-- VIEW CHRONIC HEAT HAZARD INDICATORS
SELECT	*
FROM
	 g20hackathon_model.hazard haz INNER JOIN g20hackathon_model.hazard_indicator hi ON hi.hazard_id = haz.core_id
WHERE haz.core_id = 'd08db675-ee1e-48fe-b9e1-b0da27de8f2b'
;

-- SAMPLE core_checksum UPDATE
--UPDATE g20hackathon_model.scenario
--	SET core_checksum = md5(concat('Unknown', 'Unknown', 'Unknown', 'Unknown')) WHERE scenario_core_id = -1
--;
