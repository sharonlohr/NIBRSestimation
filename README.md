# NIBRSestimation

SAS&reg; software programs used to calculate NIBRS estimates in 

Lohr, S. (2025). Estimating Crime Counts and Characteristics from NIBRS Data. Journal of Quantitative Criminology, doi:10.1007/s10940-025-09650-6. 

The MIT license applies to these programs (see LICENSE.txt). You are free to adapt them for use with other states provided you give attribution to the original source. Please cite the above paper when you use the software.

All data used in the programs are public domain, with source locations given in the paper.

SAS and all other SAS Institute Inc. product or service names are registered trademarks or trademarks of SAS Institute Inc., Cary, NC, USA. &reg; indicates USA registration.

The SAS software programs are to be run in the following order. All macros used in these programs are found in "NIBRS macros.sas".

**NIBRS read 2021 master file.sas**
* Reads the data from the 2021 NIBRS master file for Arizona and the 12 donor cities in the Southwest
* Calls macro READ_NIBRS
* Defines the hierarchical SRS structure so that OFFENSEH2021 contains only the most serious offense in each incident
* Defines variables in victim, property, offender files to be used for analysis

*Input files*

* NIBRS Master Data File for 2021  
* ICPSR 35158, Law Enforcement Agency Identifiers Crosswalk, http://doi.org/10.3886/ICPSR35158.v2 

*Output files* (containing info for AZ and LEAs from 12 donor cities in Southwest)

* BATCH2021: Info from BH001 = "BH" records  
* AGENCY2021: BATCH2021 merged with info from ICPSR crosswalk file giving names of LEAs, ICPSR 35158  
* ADMIN2021: Info from BH001 = "01" records  
* OFFENSEM2021: Info from BH001 = "02" records, includes all Part I offenses for each incident  
* OFFENSEH2021: Info from BH001 = "02" records, includes only most serious offense for each incident  
* PROPERTY2021: Info from BH001 = "03" records for incidents in OFFENSEH2021  
* VICTIM2021: Info from BH001 = "04" records for incidents in OFFENSEH2021  
* OFFENDER2021: Info from BH001 = "05" records for incidents in OFFENSEH2021  

**NIBRS 2021 Arizona UCR sample.sas**
* This program was tailored for Arizona and will need modification for other states
* Processes NIBRS LEA data for AZ
 * Calculate population covered by a NIBRS agency
 * Combine info for LEAs covered by another agency
* Selects stratified random sample of Arizona LEAs
* NIBRS 12-month reporters and large LEAs are selected with certainty
* Calculates Part I crime counts for NIBRS 12-month reporters
* Calculates Part I crime counts for Phoenix, Tucson, Tempe
* Calls no macros

*Input files*

* AGENCY2021: Information about Arizona LEAs  
* OFFENSEH2021: Count offenses for 2021 data  
* PHOENIX, TUCSON, TEMPE: Spreadsheets giving monthly UCR counts for these cities

*Output files*

* ARIZONA_sample_to_collect.csv: Spreadsheet listing LEAs in sample so counts can be obtained from external source  
* STRATSIZE: Population totals and sample sizes for each stratum.
Used later when analyzing crime counts and imputed data
Allows finite population correction to be used when calculating estimates
Crime counts need to be found for the sampled LEAs; copy ARIZONA_sample_to_collect.csv to AZcounts.csv
and put counts for sampled LEAs into AZcounts.csv

**NIBRS 2021 Arizona UCR count.sas**
* Calculates estimates of volumes and rates for Part I crimes in Arizona
* Calls no macros

*Input files*

* AZcounts.csv: ARIZONA_sample_to_collect.csv, with crime counts filled in for sampled LEAs  
* STRATSIZE: Allows finite population correction to be used when calculating estimates

*Output files*

* AZ crime rates estimated from sample.csv

**Import ACS demographics.sas**
* Imports demographic and other variables from American Community Survey downloads for AZ sample + donor cities
* This program was tailored for Arizona and will need modification to import variables for other locations;
it will not be needed if matching variables are obtained from another source.

*Input files*

* ACSDP1Y2021.DP05, ACSSPP1Y2021.S0201: Tables downloaded from data.census.gov

*Output files*

* ACSVARS: Variables from ACS for AZ sample + donor cities  
* ACSDONORS: Variables from ACS for donor cities

**NIBRS 2021 Arizona impute.sas**
* Creates multiply imputed NIBRS records for LEAs in AZcounts.csv
* This program will need to be modified for other states, years, to change imputation donors
* Calls macros
 * READ_NIBRS, to read NIBRS master files for 2022 and 2023 (used for imputing cities that converted to NIBRS in 2022 or 2023)
 * CALCULATE_MOS, which in turn calls macro MOS_CALC: calculates measures of size for Phoenix and Tucson
* MULTIPLE_IMPUTE_MOS, which in turn calls macro IMPUTE_SAMPLE: samples (with replacement)
from donors with probabilities proportional to measure of size (MOS)

*Input files*
* AZcounts.csv  
* ACSVARS:         Matching variables for cities where a pseudocity is to be created as imputation donor
* ACSDONORS       Matching variables for the set of donor cities
* AGENCY2021
* OFFENSEM2021
* OFFENSEH2021
* PROPERTY2021
* VICTIM2021  
* OFFENDER2021
* NIBRS Master Files for 2022 and 2023

*Output files*

* OFFENSEM2021_IMPUTED
* OFFENSEH2021_IMPUTED
* PROPERTY2021_IMPUTED
* VICTIM2021_IMPUTED
* OFFENDER2021_IMPUTED

**NIBRS 2021 analyze AZ imputed data.sas**
* Calculates estimates and confidence intervals from multiply imputed data files,
* Compares imputed data estimates with estimates calculated from NIBRS reporters alone

*Input files*

* OFFENSEM2021_IMPUTED
* OFFENSEH2021_IMPUTED
* PROPERTY2021_IMPUTED
* VICTIM2021_IMPUTED
* OFFENDER2021_IMPUTED

*Output files*

* AZ statistics from imputed data.xlsx
