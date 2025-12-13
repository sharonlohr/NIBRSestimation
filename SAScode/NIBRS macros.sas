%MACRO READ_NIBRS(
   YEAR          = /* YEAR TO BE READ */
  ,FNAME         = /* FILENAME GIVING LOCATION OF THE NIBRS FILE TO BE READ */
  ,STATENUM      = /* STATE NUMBER TO BE READ */
  ,AGCYLIST      = /* ADDITIONAL LIST OF ORIS TO BE READ */
   );

/* Read NIBRS Master Data File for specified year, state, and additional cities.
   Define hierarchical offense structure for calculating SRS crime rates and for imputing incidents. */

/* NIBRS Master Data File location FNAME must be defined in FILENAME statement before calling macro: for example,
   FILENAME FNAME "filepath"; */

/* OUTPUT DATA SETS */
/* BATCH&YEAR CONTAINS LEA INFORMATION */
/* ADMIN&YEAR CONTAINS ADMINISTRATIVE INFORMATION FOR EACH INCIDENT, INCLUDING NUMBER OF VICTIM, OFFENDER SEGMENTS */
/* OFFENSEM&YEAR MERGES OFFENSE FILE WITH AGENCY INFORMATION,
    DEFINES EXTRA VARIABLES
       HIER_OFF = OFFENSE (MURDER, RAPE, ROBBERY, AGASSLT, BURGLARY, LARCENY, MVTHEFT)
       OFFENSE_NUM GIVING HIERARCHICAL ORDERING OF OFFENSES.
    KEEPS ONLY INCIDENTS WITH PART I OFFENSES */
/* OFFENSEH&YEAR KEEPS ONLY MOST SERIOUS OFFENSE IN OFFENSEM&YEAR */
/* PROPERTY&YEAR IS PROPERTY FILE FOR INCIDENTS RETAINED IN OFFENSEH&YEAR */
/* VICTIM&YEAR IS VICTIM FILE FOR INCIDENTS RETAINED IN OFFENSEH&YEAR */
/* OFFENDER&YEAR IS OFFENDER FILE FOR INCIDENTS RETAINED IN OFFENSEH&YEAR */

   %PUT &YEAR;

DATA BATCH&YEAR ADMIN&YEAR OFFENSE&YEAR PROPERTY&YEAR VICTIM&YEAR OFFENDER&YEAR;
   INFILE &FNAME;
   RETAIN YEAR &YEAR;
   INPUT BH001 $ 1-2 @;
   IF BH001 = "BH" THEN DO; /* PAGE 20 OF CODEBOOK, DATE_ORI_ADDED IS MISSING FOR ALL IN AZ */
      INPUT NUMSTATE 3-4 ORI $ 5-13 DATE_ORI_ADDED 26-33 DATE_ORI_NIBRS 34-41
         CITY_NAME $ 42-71 STATE_ABB $ 72-73 POP_GROUP $ 74-75 COUNTRY_DIVISION 76
         REGION 77 AGENCY_INDICATOR 78 CORE_CITY $ 79 COVERED_BY_ORI $ 80-88
         NIBRS_FLAG $97 CURRENT_POPULATION 106-114 UCR_COUNTY_CODE 115-117 MSA_CODE $ 118-120
         CURRENT_POPULATION_2 130-138 UCR_COUNTY_CODE_2 139-141 MSA_CODE_2 $ 142-144
         CURRENT_POPULATION_3 154-162 UCR_COUNTY_CODE_3 163-165 MSA_CODE_3 $ 166-168
         INDICATOR_01_06_12 226-227 MONTHS_REPORTED 228-229 
         JAN_ACT $ 234-236 FEB_ACT $ 237-239 MAR_ACT $ 240-242 APR_ACT $ 243-245
         MAY_ACT $ 246-248 JUN_ACT $ 249-251 JUL_ACT $ 252-254 AUG_ACT $ 255-257
         SEP_ACT $ 258-260 OCT_ACT $ 261-263 NOV_ACT $ 264-266 DEC_ACT $ 267-269
         FIPS_COUNTY_1 270-272 FIPS_COUNTY_2 273-275 FIPS_COUNTY_3 276-278;
         IF 0 < MONTHS_REPORTED LE 12 THEN ANY_NIBRS = 1;
          ELSE IF MONTHS_REPORTED = 0 THEN ANY_NIBRS = 0;
          ELSE IF 3 LE MONTHS_REPORTED LE 12 THEN THREE_NIBRS = 1;
          ELSE IF MONTHS_REPORTED LE 2 THEN THREE_NIBRS = 0;
         IF NIBRS_FLAG = "A" AND MONTHS_REPORTED = 12 THEN PARTICIPATE = 3;
          ELSE IF NIBRS_FLAG = "A" AND MONTHS_REPORTED >= 3 AND MONTHS_REPORTED < 12 THEN PARTICIPATE = 2;
          ELSE IF NIBRS_FLAG = "A" AND MONTHS_REPORTED > 0 AND MONTHS_REPORTED < 3 THEN PARTICIPATE = 1;
          ELSE PARTICIPATE = 0;
      IF NUMSTATE = &STATENUM OR ORI IN &AGCYLIST THEN OUTPUT BATCH&YEAR;
   END;
  ELSE IF BH001 = "01" THEN DO; /* ADMIN FILE FOR INCIDENT, PAGE 42 OF CODEBOOK */
      INPUT NUMSTATE 3-4 ORI $ 5-13 INCIDENT_NUMBER $ 14-25 INCIDENT_DATE 26-33
	  REPORT_DATE_INDICATOR $ 34 INCIDENT_DATE_HOUR 35-36
      TOTAL_OFFENSE_SEGMENTS 37-38 TOTAL_VIC_SEGMENTS 39-41 TOTAL_OFFENDER_SEGMENTS 42-43
	  CITY_SUBMISSION $ 46-49 
      OFF1 $ 59-61 OFF2 $ 62-64 OFF3 $ 65-67 OFF4 $ 68-70 OFF5 $ 71-73 OFF6 $ 74-76 OFF7 $ 77-79 OFF8 $ 80-82 OFF9 $ 83-85 OFF10 $ 86-88;
	  IF NUMSTATE = &STATENUM OR ORI IN &AGCYLIST THEN OUTPUT ADMIN&YEAR;
   END;
   ELSE IF BH001 = "02" THEN DO; /* PAGE 46 OF CODEBOOK */
      INPUT NUMSTATE 3-4 ORI $ 5-13 INCIDENT_NUMBER $ 14-25 INCIDENT_DATE 26-33 UCR_OFFENSE $ 34-36 ATTEMPT_COMPLETE $ 37 
        OFFENDER_SUSP_USING $ 38-40 LOCATION_TYPE 41-42 METHOD_OF_ENTRY $ 45 TYPE_CRIMINAL_ACTIVITY $ 46-48 
        WEAPON_1 49-50 AUTO_WEAPON_1 $ 51 WEAPON_2 52-53 AUTO_WEAPON_2 $ 54 
        WEAPON_3 55-56 AUTO_WEAPON_3 $ 57 BIAS 58-59;
	  IF NUMSTATE = &STATENUM OR ORI IN &AGCYLIST THEN OUTPUT OFFENSE&YEAR;
   END;
   ELSE IF BH001 = "03" THEN DO; /* PAGE 54 OF CODEBOOK */
      INPUT NUMSTATE 3-4 ORI $ 5-13 INCIDENT_NUMBER $ 14-25 INCIDENT_DATE 26-33 
        TYPE_PROPERTY_LOSS 34 PROPERTY_DESCRIPTION 35-36 PROPERTY_VALUE $ 37-45 DATE_RECOVERED 46-53;
	  IF NUMSTATE = &STATENUM OR ORI IN &AGCYLIST THEN OUTPUT PROPERTY&YEAR;
   END;
   ELSE IF BH001 = "04" THEN DO; /* PAGE 62 OF CODEBOOK */
      INPUT NUMSTATE 3-4 ORI $ 5-13 INCIDENT_NUMBER $ 14-25 INCIDENT_DATE 26-33 
        VICTIM_SEQ_NUMBER 34-36 
        UCR_OFF_CODE_1 $ 37-39 UCR_OFF_CODE_2 $ 40-42 UCR_OFF_CODE_3 $ 43-45 UCR_OFF_CODE_4 $ 46-48
        UCR_OFF_CODE_5 $ 49-51 UCR_OFF_CODE_6 $ 52-54 UCR_OFF_CODE_7 $ 55-57 UCR_OFF_CODE_8 $ 58-60
        UCR_OFF_CODE_9 $ 61-63 UCR_OFF_CODE_10 $ 64-66
        VICTIM_TYPE $ 67 VICTIM_AGE $ 68-69 VICTIM_SEX $ 70 VICTIM_RACE $ 71 VICTIM_ETH $ 72
        CIRCUMSTANCE_1 74-75 CIRCUMSTANCE_2 76-77
        INJURY_1 $ 79 INJURY_2 $ 80 INJURY_3 $ 81
        OFFENDER_NUM_1 84-85 VICTIM_REL_TO_OFFENDER_1 $ 86-87
        OFFENDER_NUM_2 88-89 VICTIM_REL_TO_OFFENDER_2 $ 90-91
        OFFENDER_NUM_3 92-93 VICTIM_REL_TO_OFFENDER_3 $ 94-95
        OFFENDER_NUM_4 96-97 VICTIM_REL_TO_OFFENDER_4 $ 98-99
        OFFENDER_NUM_5 100-101 VICTIM_REL_TO_OFFENDER_5 $ 102-103
        OFFENDER_NUM_6 104-105 VICTIM_REL_TO_OFFENDER_6 $ 106-107
        OFFENDER_NUM_7 108-109 VICTIM_REL_TO_OFFENDER_7 $ 110-111
        OFFENDER_NUM_8 112-113 VICTIM_REL_TO_OFFENDER_8 $ 114-115
        OFFENDER_NUM_9 116-117 VICTIM_REL_TO_OFFENDER_9 $ 118-119
        OFFENDER_NUM_10 120-121 VICTIM_REL_TO_OFFENDER_10 $ 122-123;
	  IF NUMSTATE = &STATENUM OR ORI IN &AGCYLIST THEN OUTPUT VICTIM&YEAR;
   END;  
   ELSE IF BH001 = "05" THEN DO; /* PAGE 46 OF CODEBOOK */
      INPUT NUMSTATE 3-4 ORI $ 5-13 INCIDENT_NUMBER $ 14-25 INCIDENT_DATE 26-33 
        OFFENDER_SEQ_NUMBER $ 34-35 OFFENDER_AGE 36-37 OFFENDER_SEX $ 38
        OFFENDER_RACE $ 39 ;
	  IF NUMSTATE = &STATENUM OR ORI IN &AGCYLIST THEN OUTPUT OFFENDER&YEAR;
   END;
RUN;

DATA BATCH&YEAR (KEEP = YEAR NUMSTATE ORI DATE_ORI_ADDED DATE_ORI_NIBRS 
         CITY_NAME STATE_ABB POP_GROUP COUNTRY_DIVISION 
         REGION AGENCY_INDICATOR CORE_CITY COVERED_BY_ORI 
         NIBRS_FLAG INDICATOR_01_06_12 MONTHS_REPORTED PARTICIPATE ANY_NIBRS THREE_NIBRS
         CURRENT_POPULATION UCR_COUNTY_CODE MSA_CODE FIPS_COUNTY_1 
         CURRENT_POPULATION_2 UCR_COUNTY_CODE_2 MSA_CODE_2 FIPS_COUNTY_2
         CURRENT_POPULATION_3 UCR_COUNTY_CODE_3 MSA_CODE_3 FIPS_COUNTY_3
         JAN_ACT FEB_ACT MAR_ACT APR_ACT 
         MAY_ACT JUN_ACT JUL_ACT AUG_ACT 
         SEP_ACT OCT_ACT NOV_ACT DEC_ACT );
   SET BATCH&YEAR;
RUN;

/* DEFINE HIERARCHICAL OFFENSE STRUCTURE. DELETE OFFENSES NOT IN PART I. */

DATA OFFENSEM&YEAR (KEEP = YEAR NUMSTATE ORI INCIDENT_NUMBER INCIDENT_DATE UCR_OFFENSE ATTEMPT_COMPLETE 
        OFFENDER_SUSP_USING  LOCATION_TYPE  METHOD_OF_ENTRY  TYPE_CRIMINAL_ACTIVITY 
        WEAPON_1  AUTO_WEAPON_1  WEAPON_2  AUTO_WEAPON_2  
        WEAPON_3  AUTO_WEAPON_3  BIAS HIER_OFF OFFENSE_NUM VIOL_CRIME PROP_CRIME
        OFFENSE_TYPE VIOL_OFFENSE PROP_OFFENSE MURDER RAPE ROBBERY AGASSLT BURGLARY LARCENY MVTHEFT WEAPON WEAPON_KNOWN
        WEAPON_TYPE_KNOWN);
   LENGTH HIER_OFF $ 8 OFFENSE_TYPE $ 8 WEAPON $ 8 WEAPON_KNOWN $ 8;
   ARRAY _VIOL_TYPE {4} MURDER RAPE ROBBERY AGASSLT;
   ARRAY _PROP_TYPE {3} BURGLARY LARCENY MVTHEFT;
   ARRAY _CRIME_TYPE {7} MURDER RAPE ROBBERY AGASSLT BURGLARY LARCENY MVTHEFT;
   SET OFFENSE&YEAR;
   DO J = 1 TO 7;
      _CRIME_TYPE{J} = 0;
   END;
   IF UCR_OFFENSE IN ("09A","09B") THEN DO;
      OFFENSE_TYPE = "MURDER";
      MURDER = 1;
	  OFFENSE_NUM = 1;
   END;
   ELSE IF UCR_OFFENSE IN ("11A","11B","11C") THEN DO;
      OFFENSE_TYPE = "RAPE";
      RAPE = 1;
	  OFFENSE_NUM = 2;
   END;   
   ELSE IF UCR_OFFENSE IN ("120") THEN DO;
      OFFENSE_TYPE = "ROBBERY";
      ROBBERY = 1;
	  OFFENSE_NUM = 3;
   END;
   ELSE IF UCR_OFFENSE IN ("13A") THEN DO;
      OFFENSE_TYPE = "AGASSLT";
      AGASSLT = 1;
	   OFFENSE_NUM = 4;
   END;
   ELSE IF UCR_OFFENSE IN ("220") THEN DO;
      OFFENSE_TYPE = "BURGLARY";
      BURGLARY = 1;
	   OFFENSE_NUM = 5;
   END;
   ELSE IF UCR_OFFENSE IN ("240") THEN DO;
      OFFENSE_TYPE = "MVTHEFT";
      MVTHEFT = 1;
	   OFFENSE_NUM = 6;
   END;
   ELSE IF UCR_OFFENSE IN ("23A","23B","23C","23D","23E","23F","23G","23H") THEN DO;
      OFFENSE_TYPE = "LARCENY";
      LARCENY = 1;
	   OFFENSE_NUM = 7;
   END;

   IF OFFENSE_TYPE IN ('MURDER','RAPE','ROBBERY','AGASSLT') THEN VIOL_OFFENSE = 1; ELSE VIOL_OFFENSE = 0;
   IF OFFENSE_TYPE IN ('MVTHEFT','LARCENY','BURGLARY') THEN PROP_OFFENSE = 1; ELSE PROP_OFFENSE = 0;

   HIER_OFF = OFFENSE_TYPE;
   VIOL_CRIME = VIOL_OFFENSE;
   PROP_CRIME = PROP_OFFENSE;

   WEAPON = " ";
   IF WEAPON_1 IN (11,12,13,14,15) OR WEAPON_2 IN (11,12,13,14,15) OR WEAPON_3 IN (11,12,13,14,15) 
         THEN WEAPON = "GUN";		 
   ELSE IF WEAPON_1 IN (20) OR WEAPON_2 IN (20) OR WEAPON_3 IN (20) THEN WEAPON = "KNIFE";
   ELSE IF WEAPON_1 IN (30) OR WEAPON_2 IN (30) OR WEAPON_3 IN (30) THEN WEAPON = "BLUNTOBJ";
   ELSE IF WEAPON_1 IN (40) OR WEAPON_2 IN (40) OR WEAPON_3 IN (40) THEN WEAPON = "PERSONAL";
   ELSE IF WEAPON_1 IN (35,50,60,65,70,85,90) OR WEAPON_2 IN (35,50,60,65,70,85,90) OR WEAPON_3 IN (35,50,60,65,70,85,90) 
         THEN WEAPON = "PERSONAL";
   ELSE IF WEAPON_1 IN (99) OR WEAPON_2 IN (99) OR WEAPON_3 IN (99) THEN WEAPON = "NONE";
   ELSE IF WEAPON_1 IN (95) OR WEAPON_2 IN (95) OR WEAPON_3 IN (95) THEN WEAPON = "UNKNOWN";
   WEAPON_KNOWN = WEAPON;
   IF WEAPON = "UNKNOWN" THEN WEAPON_KNOWN = " ";
   WEAPON_TYPE_KNOWN = WEAPON_KNOWN;
   IF WEAPON = "NONE" THEN WEAPON_TYPE_KNOWN = " ";

   IF OFFENSE_NUM IN (1,2,3,4,5,6,7);  /* KEEP ONLY PART I CRIMES */
RUN;

PROC SORT DATA=OFFENSEM&YEAR;
   BY ORI INCIDENT_NUMBER OFFENSE_NUM;
RUN;

/* OFFENSEH&YEAR HAS ONLY MOST SERIOUS OFFENSE PER INCIDENT */

DATA OFFENSEH&YEAR;
   SET OFFENSEM&YEAR;
   BY ORI INCIDENT_NUMBER;
   IF FIRST.INCIDENT_NUMBER;
RUN;

/* REMOVE HIERARCHICAL CRIME INFORMATION FROM OFFENSEM&YEAR SINCE REDUNDANT FOR THAT FILE */

DATA OFFENSEM&YEAR (DROP = HIER_OFF OFFENSE_NUM VIOL_CRIME PROP_CRIME);
   SET OFFENSEM&YEAR;
RUN;

/* KEEP ONLY INCIDENTS FOUND IN OFFENSEH&YEAR FOR ADMIN, CRIME CHARACTERISTIC DATASETS */

DATA INCIDENT_KEEP (KEEP = NUMSTATE ORI INCIDENT_NUMBER IN_OFFENSEH);
  SET OFFENSEH&YEAR;
  IN_OFFENSEH = 1;
RUN;


DATA INCIDENT_KEEP_OFFENDER (KEEP = NUMSTATE ORI INCIDENT_NUMBER IN_OFFENSEH HIER_OFF VIOL_CRIME PROP_CRIME);
  SET OFFENSEH&YEAR;
  IN_OFFENSEH = 1;
RUN;

PROC SORT DATA=INCIDENT_KEEP;
  BY NUMSTATE ORI INCIDENT_NUMBER;

PROC SORT DATA=INCIDENT_KEEP_OFFENDER;
  BY NUMSTATE ORI INCIDENT_NUMBER;

PROC SORT DATA=ADMIN&YEAR;
  BY NUMSTATE ORI INCIDENT_NUMBER;

PROC SORT DATA=VICTIM&YEAR;
  BY NUMSTATE ORI INCIDENT_NUMBER;

PROC SORT DATA=OFFENDER&YEAR;
  BY NUMSTATE ORI INCIDENT_NUMBER;

PROC SORT DATA=PROPERTY&YEAR;
  BY NUMSTATE ORI INCIDENT_NUMBER;


DATA ADMIN&YEAR (KEEP = YEAR NUMSTATE ORI INCIDENT_NUMBER INCIDENT_DATE INCIDENT_DATE_HOUR TOTAL_OFFENSE_SEGMENTS TOTAL_VIC_SEGMENTS TOTAL_OFFENDER_SEGMENTS);
  MERGE ADMIN&YEAR INCIDENT_KEEP;
  BY NUMSTATE ORI INCIDENT_NUMBER;
  IF IN_OFFENSEH = 1;
RUN;

DATA VICTIM&YEAR (KEEP = YEAR NUMSTATE ORI INCIDENT_NUMBER INCIDENT_DATE VICTIM_SEQ_NUMBER UCR_OFF_CODE_1 UCR_OFF_CODE_2 UCR_OFF_CODE_3 UCR_OFF_CODE_4 
VICTIM_TYPE VICTIM_AGE VICTIM_SEX VICTIM_RACE VICTIM_ETH CIRCUMSTANCE_1 CIRCUMSTANCE_2 
INJURY_1 INJURY_2 INJURY_3 
        OFFENDER_NUM_1-OFFENDER_NUM_10  VICTIM_REL_TO_OFFENDER_1-VICTIM_REL_TO_OFFENDER_10  );
  MERGE VICTIM&YEAR INCIDENT_KEEP;
  BY NUMSTATE ORI INCIDENT_NUMBER;
  IF IN_OFFENSEH = 1;
RUN;

DATA VICTIM&YEAR;
  LENGTH VICTIM_RELATION_1-VICTIM_RELATION_10 $ 12 VICTIM_REL_HIER $ 12 VICTIM_AGE_GROUP $ 8 VICTIM_AGE_DECILE $ 8;
  ARRAY UCR_OFFENSE_CODES{4} $ UCR_OFF_CODE_1 - UCR_OFF_CODE_4;
  ARRAY VICTIM_RELATION{10} $ VICTIM_RELATION_1-VICTIM_RELATION_10;
  ARRAY VICTIM_REL_TO_OFFENDER{10} $ VICTIM_REL_TO_OFFENDER_1-VICTIM_REL_TO_OFFENDER_10;
  SET VICTIM&YEAR;
   IF ORI NE ' ' THEN DO;
      MURDER = 0;
	  RAPE = 0;
	  ROBBERY = 0;
	  AGASSLT = 0;
	  BURGLARY = 0;
	  LARCENY = 0;
	  MVTHEFT = 0;
	  VIOL_OFFENSE = 0;
	  PROP_OFFENSE = 0;
   END;
   DO J = 1 TO 4;
      IF UCR_OFFENSE_CODES{J} IN ("09A","09B") THEN MURDER = 1;
      IF UCR_OFFENSE_CODES{J} IN ("11A","11B","11C") THEN RAPE = 1;
      IF UCR_OFFENSE_CODES{J} IN ("120") THEN ROBBERY = 1;
      IF UCR_OFFENSE_CODES{J} IN ("13A") THEN AGASSLT = 1;
      IF UCR_OFFENSE_CODES{J} IN ("220") THEN BURGLARY = 1;
      IF UCR_OFFENSE_CODES{J} IN ("240") THEN MVTHEFT = 1;
      IF UCR_OFFENSE_CODES{J} IN ("23A","23B","23C","23D","23E","23F","23G","23H") THEN LARCENY = 1;
   END;     
   IF MURDER + RAPE + ROBBERY + AGASSLT GE 1 THEN VIOL_OFFENSE = 1; 
   IF MVTHEFT + LARCENY + BURGLARY GE 1 THEN PROP_OFFENSE = 1; 
   VICTIM_AGE_NUM = INPUT(VICTIM_AGE,??32.);
   IF VICTIM_AGE IN ("00") THEN VICTIM_AGE_NUM = .;
   IF VICTIM_AGE IN ("NN","NB","BB") THEN VICTIM_AGE_NUM = 0;
   IF VICTIM_AGE_NUM GE 0 AND VICTIM_AGE_NUM < 5 THEN VICTIM_AGE_GROUP = "UNDER 5";
    ELSE IF VICTIM_AGE_NUM GE 5 AND VICTIM_AGE_NUM < 18 THEN VICTIM_AGE_GROUP = "5-17";
    ELSE IF VICTIM_AGE_NUM GE 18 AND VICTIM_AGE_NUM < 24 THEN VICTIM_AGE_GROUP = "18-24";
    ELSE IF VICTIM_AGE_NUM GE 25 AND VICTIM_AGE_NUM < 34 THEN VICTIM_AGE_GROUP = "25-34";
    ELSE IF VICTIM_AGE_NUM GE 35 AND VICTIM_AGE_NUM < 44 THEN VICTIM_AGE_GROUP = "35-44";
    ELSE IF VICTIM_AGE_NUM GE 45 AND VICTIM_AGE_NUM < 54 THEN VICTIM_AGE_GROUP = "45-54";
    ELSE IF VICTIM_AGE_NUM GE 55 AND VICTIM_AGE_NUM < 64 THEN VICTIM_AGE_GROUP = "55-64";
    ELSE IF VICTIM_AGE_NUM GE 65 AND VICTIM_AGE_NUM < 100 THEN VICTIM_AGE_GROUP = "OVER 65";
   IF VICTIM_AGE_NUM GE 0 AND VICTIM_AGE_NUM < 10 THEN VICTIM_AGE_DECILE = "0 TO 9";
    ELSE IF VICTIM_AGE_NUM GE 10 AND VICTIM_AGE_NUM < 20 THEN VICTIM_AGE_DECILE = "10-19";
    ELSE IF VICTIM_AGE_NUM GE 20 AND VICTIM_AGE_NUM < 30 THEN VICTIM_AGE_DECILE = "20-29";
    ELSE IF VICTIM_AGE_NUM GE 30 AND VICTIM_AGE_NUM < 40 THEN VICTIM_AGE_DECILE = "30-39";
    ELSE IF VICTIM_AGE_NUM GE 40 AND VICTIM_AGE_NUM < 50 THEN VICTIM_AGE_DECILE = "40-49";
    ELSE IF VICTIM_AGE_NUM GE 50 AND VICTIM_AGE_NUM < 60 THEN VICTIM_AGE_DECILE = "50-59";
    ELSE IF VICTIM_AGE_NUM GE 60 AND VICTIM_AGE_NUM < 70 THEN VICTIM_AGE_DECILE = "60-69";
    ELSE IF VICTIM_AGE_NUM GE 70 AND VICTIM_AGE_NUM < 80 THEN VICTIM_AGE_DECILE = "70-79";
    ELSE IF VICTIM_AGE_NUM GE 80 AND VICTIM_AGE_NUM < 90 THEN VICTIM_AGE_DECILE = "80-89";
    ELSE IF VICTIM_AGE_NUM GE 90 AND VICTIM_AGE_NUM < 100 THEN VICTIM_AGE_DECILE = "90-OLDER";
   IF VICTIM_AGE_NUM GE 0 AND VICTIM_AGE_NUM < 18 THEN VICTIM_AGE_UNDER_18 = 1;
    ELSE IF VICTIM_AGE_NUM GE 18 AND VICTIM_AGE_NUM < 100 THEN VICTIM_AGE_UNDER_18 = 0;
   DO J = 1 TO DIM(VICTIM_RELATION);
    IF VICTIM_REL_TO_OFFENDER{J} IN ("SE","CS","PA","SB","CH","GP","GC","IL","SP","SC","SS","OF","VO") 
          THEN DO;
             VICTIM_RELATION{J} = "FAMILY";
			 ANYREL_FAMILY = 1;
			 ANYREL_KNOWN = 1;
		  END;
    ELSE IF VICTIM_REL_TO_OFFENDER{J} IN ("AQ","FR","NE","BE","BG","CF","HR","XS","EE","ER","OK") 
          THEN DO;
             VICTIM_RELATION{J} = "NOTFAM/KNOWN";
			 ANYREL_KNOWN = 1;
		  END;
    ELSE IF VICTIM_REL_TO_OFFENDER{J} IN ("ST") THEN DO;
             VICTIM_RELATION{J} = "STRANGER";
			 ANYREL_STRANGER = 1;
		  END;
    ELSE IF VICTIM_REL_TO_OFFENDER{J} IN ("RU") THEN VICTIM_RELATION{J} = "REL_UNKNOWN";
   END; /* DO LOOP OVER VICTIM RELATIONS */
   IF (ANYREL_FAMILY NE 1 OR ANYREL_FAMILY = .) AND (ANYREL_KNOWN + ANYREL_STRANGER GE 1) THEN ANYREL_FAMILY = 0;
   IF (ANYREL_KNOWN NE 1 OR ANYREL_KNOWN = .) AND ANYREL_STRANGER = 1 THEN ANYREL_KNOWN = 0;
   IF ANYREL_FAMILY = 1 THEN VICTIM_REL_HIER = "FAMILY";
   ELSE IF ANYREL_KNOWN = 1 THEN VICTIM_REL_HIER = "NOTFAM/KNOWN";
   ELSE IF ANYREL_STRANGER = 1 THEN VICTIM_REL_HIER = "STRANGER";
   VICTIM_SEX_KNOWN = VICTIM_SEX;
   IF VICTIM_SEX = 'U' THEN VICTIM_SEX_KNOWN = ' ';
   VICTIM_RACE_KNOWN = VICTIM_RACE;
   IF VICTIM_RACE = 'U' THEN VICTIM_RACE_KNOWN = ' ';
   VICTIM_ETH_KNOWN = VICTIM_ETH;
   IF VICTIM_ETH = 'U' THEN VICTIM_ETH_KNOWN = ' ';

RUN;

DATA OFFENDER&YEAR (KEEP = YEAR NUMSTATE ORI INCIDENT_NUMBER INCIDENT_DATE 
     OFFENDER_SEQ_NUMBER OFFENDER_AGE OFFENDER_SEX OFFENDER_RACE HIER_OFF VIOL_CRIME PROP_CRIME);
  MERGE OFFENDER&YEAR INCIDENT_KEEP_OFFENDER;
  BY NUMSTATE ORI INCIDENT_NUMBER;
  IF IN_OFFENSEH = 1;
RUN;

DATA OFFENDER&YEAR;
  LENGTH OFFENDER_AGE_GROUP $ 8 OFFENDER_AGE_DECILE $ 8;
  SET OFFENDER&YEAR;
   OFFENDER_AGE_NUM = OFFENDER_AGE;
   IF OFFENDER_AGE IN (0) THEN OFFENDER_AGE_NUM = .;
   IF OFFENDER_AGE_NUM GE 0 AND OFFENDER_AGE_NUM < 5 THEN OFFENDER_AGE_GROUP = "00-05";
    ELSE IF OFFENDER_AGE_NUM GE 5 AND OFFENDER_AGE_NUM < 18 THEN OFFENDER_AGE_GROUP = "05-17";
    ELSE IF OFFENDER_AGE_NUM GE 18 AND OFFENDER_AGE_NUM < 24 THEN OFFENDER_AGE_GROUP = "18-24";
    ELSE IF OFFENDER_AGE_NUM GE 25 AND OFFENDER_AGE_NUM < 34 THEN OFFENDER_AGE_GROUP = "25-34";
    ELSE IF OFFENDER_AGE_NUM GE 35 AND OFFENDER_AGE_NUM < 44 THEN OFFENDER_AGE_GROUP = "35-44";
    ELSE IF OFFENDER_AGE_NUM GE 45 AND OFFENDER_AGE_NUM < 54 THEN OFFENDER_AGE_GROUP = "45-54";
    ELSE IF OFFENDER_AGE_NUM GE 55 AND OFFENDER_AGE_NUM < 64 THEN OFFENDER_AGE_GROUP = "55-64";
    ELSE IF OFFENDER_AGE_NUM GE 65 AND OFFENDER_AGE_NUM < 100 THEN OFFENDER_AGE_GROUP = "65+";
   IF OFFENDER_AGE_NUM GE 0 AND OFFENDER_AGE_NUM LT 18 THEN OFFENDER_AGE_UNDER_18 = 1;
    ELSE IF OFFENDER_AGE_NUM GE 18 AND OFFENDER_AGE_NUM LT 100 THEN OFFENDER_AGE_UNDER_18 = 0;
   IF OFFENDER_AGE_NUM GE 0 AND OFFENDER_AGE_NUM < 10 THEN OFFENDER_AGE_DECILE = "0 TO 9";
    ELSE IF OFFENDER_AGE_NUM GE 10 AND OFFENDER_AGE_NUM < 20 THEN OFFENDER_AGE_DECILE = "10-19";
    ELSE IF OFFENDER_AGE_NUM GE 20 AND OFFENDER_AGE_NUM < 30 THEN OFFENDER_AGE_DECILE = "20-29";
    ELSE IF OFFENDER_AGE_NUM GE 30 AND OFFENDER_AGE_NUM < 40 THEN OFFENDER_AGE_DECILE = "30-39";
    ELSE IF OFFENDER_AGE_NUM GE 40 AND OFFENDER_AGE_NUM < 50 THEN OFFENDER_AGE_DECILE = "40-49";
    ELSE IF OFFENDER_AGE_NUM GE 50 AND OFFENDER_AGE_NUM < 60 THEN OFFENDER_AGE_DECILE = "50-59";
    ELSE IF OFFENDER_AGE_NUM GE 60 AND OFFENDER_AGE_NUM < 70 THEN OFFENDER_AGE_DECILE = "60-69";
    ELSE IF OFFENDER_AGE_NUM GE 70 AND OFFENDER_AGE_NUM < 80 THEN OFFENDER_AGE_DECILE = "70-79";
    ELSE IF OFFENDER_AGE_NUM GE 80 AND OFFENDER_AGE_NUM < 90 THEN OFFENDER_AGE_DECILE = "80-89";
    ELSE IF OFFENDER_AGE_NUM GE 90 AND OFFENDER_AGE_NUM < 100 THEN OFFENDER_AGE_DECILE = "90-OLDER";
   OFFENDER_SEX_KNOWN = OFFENDER_SEX;
   IF OFFENDER_SEX = 'U' THEN OFFENDER_SEX_KNOWN = ' ';
   OFFENDER_RACE_KNOWN = OFFENDER_RACE;
   IF OFFENDER_RACE = 'U' THEN OFFENDER_RACE_KNOWN = ' ';
RUN;

DATA PROPERTY&YEAR (KEEP = YEAR NUMSTATE ORI INCIDENT_NUMBER INCIDENT_DATE
     TYPE_PROPERTY_LOSS PROPERTY_DESCRIPTION);
  MERGE PROPERTY&YEAR INCIDENT_KEEP;
  BY NUMSTATE ORI INCIDENT_NUMBER;
  IF IN_OFFENSEH = 1;
RUN;

%MEND READ_NIBRS;


/* ***Macros for imputing NIBRS records for sampled responding and partially responding agencies *** */

/* THE FOLLOWING USES ANNUAL COUNTS, CAN BE MODIFIED TO TAKE ADVANTAGE OF MONTHLY INFO */

%MACRO IMPUTE_SAMPLE(
   LEA_COUNTS     =   /* Input  Name of dataset giving SRS incident counts for NIBRS nonreporters, wide format.
                                Must have columns of counts with same names as HIER_OFFs in DONORSET  */
  ,BASE_DATA      =   /* Input  Name of dataset giving incidents (hierarchical) for full NIBRS reporters */
  ,DONORSET       =   /* Input  Name of dataset to be used to obtain incidents for hot deck donors */
  ,SEED_IMPUTE    =   /* Input  Random number seed to use for starting the imputation */
  ,OUTDATA        =   /* Output Name of output data file containing imputed crime incidents */
                      /* Contains variables
                         ORI_SAMPLE      ORI for unit with imputed or actual NIBRS records
                         ORI             ORI for imputation donor (for use in merging with NIBRS files)
                         STRATUM         Stratum number for ORI_SAMPLE
                         LEA_WT          Sampling weight for LEAs in ORI_SAMPLE 
                         IMPUTE_FLAG     = 1 IF IMPUTED, 0 IF NOT IMPUTED
                         and variables from hierarchical incident file OFFENSEH */
);

%LOCAL J;
%LOCAL SEEDITER;

/* CREATES AN IMPUTATION SET OF NIBRS RECORDS */

/* COUNT THE NUMBER OF LEAS TO BE IMPUTED */

%LET DSID     = %SYSFUNC(OPEN(WORK.&LEA_COUNTS));
%LET _NUM_LEAS = %SYSFUNC(ATTRN(&DSID,NLOBS));
%LET RC       = %SYSFUNC(CLOSE(&DSID));
%PUT &_NUM_LEAS;

/* PUT &BASE_DATA INTO EACH IMPUTED DATASET */


  DATA &OUTDATA;
     LENGTH ORI_SAMPLE $ 9;
     SET &BASE_DATA;
     ORI_SAMPLE = ORI;
     IMPUTE_FLAG = 0;
  RUN;


 %DO J = 1 %TO &_NUM_LEAS;

  /* CREATE DATASET WITH COUNTS FOR JTH LEA TO BE IMPUTED, CONVERT TO LONG FORMAT */

   DATA _LEA_COUNT (DROP = CURRENT_POPULATION MONTHS_REPORTED PARTICIPATE);
      SET &LEA_COUNTS (FIRSTOBS = &J OBS = &J);
   RUN;

   PROC SORT DATA=_LEA_COUNT;
      BY STRATUM ORI LEA_WT;
   RUN;

   PROC TRANSPOSE DATA= _LEA_COUNT OUT = _IMPUTE_STRATSIZE;
      BY STRATUM ORI LEA_WT;
   RUN;

   DATA _IMPUTE_STRATSIZE (RENAME = (COL1 = _NSIZE_ _NAME_ = HIER_OFF));
     SET _IMPUTE_STRATSIZE;
     ORI_SAMPLE = ORI;
     CALL SYMPUT('ORI_SAMPLE',ORI_SAMPLE);
   RUN;

  /* &ORI_SAMPLE IS ORI OF THE SAMPLED LEA WHOSE RECORDS ARE TO BE IMPUTED */


  %PUT &ORI_SAMPLE;
  %LET MOS = MOS_&ORI_SAMPLE;
  %PUT &MOS;

  DATA _DONORS;
     SET &DONORSET;
     IF &MOS > 0;
  RUN;

  PROC SORT DATA=_IMPUTE_STRATSIZE;
     BY HIER_OFF;

  PROC SORT DATA=_DONORS;
     BY HIER_OFF;

  %LET SEEDITER = %EVAL(&SEED_IMPUTE + %EVAL(&J-1)) ;
  %PUT SEEDITER = &SEEDITER ;

/* IMPORTANT: USE OPTION OUTHITS SO OUTPUT FILE LISTS EACH RECORD AS MANY TIMES AS IT APPEARS IN THE WITH-REPLACEMENT SAMPLE. */

  PROC SURVEYSELECT DATA = _DONORS METHOD = PPS_WR SAMPSIZE = _IMPUTE_STRATSIZE OUTHITS OUT = _IMPUTE_OUT SEED = &SEEDITER;
     SIZE &MOS;
     STRATA HIER_OFF;
     TITLE 'SELECT IMPUTED RECORDS';
  RUN;

  /* PUT ORI OF IMPUTED LEA INTO ORI_SAMPLE FOR MERGING WITH IMPUTED RECORDS */
  DATA _LEA_COUNT_MERGE (KEEP = ORI_SAMPLE STRATUM LEA_WT);
     SET _LEA_COUNT;
     ORI_SAMPLE = ORI;
  ;

  DATA _IMPUTE_OUT (DROP = SAMPLINGWEIGHT NUMBERHITS EXPECTEDHITS);
     SET _IMPUTE_OUT;
	 IF _N_ = 1 THEN DO;
	    SET _LEA_COUNT_MERGE;
	 END;
     IMPUTE_FLAG = 1;
  RUN; 

/* APPEND IMPUTED DATA FOR SAMPLE_ORI TO &OUTDATA */

  DATA &OUTDATA;
      SET &OUTDATA _IMPUTE_OUT;
  RUN;

 %END; /* LOOP OVER &J */

%MEND IMPUTE_SAMPLE;


%MACRO MULTIPLE_IMPUTE(
   LEA_COUNTS     =   /* Input  Name of dataset giving SRS incident counts for NIBRS nonreporters, wide format.
                                Must have columns with same names as HIER_OFFs in DONORSET  */
  ,NUM_IMPUTE     =   /* Input  Number of imputed datasets to be formed */
  ,BASE_DATA      =   /* Input  Name of dataset giving incidents (hierarchical) for full NIBRS reporters */
  ,DONORSET       =   /* Input  Name of dataset to be used to obtain incidents for hot deck donors */
  ,SEED_START     =   /* Input  Random number seed to use for starting the imputation */
  ,M_IMPUTE_FILE  =   /* Output Name of output data file containing imputed crime incidents */
                      /* Contains variables
                         _IMPUTATION_    Imputation number
                         ORI_SAMPLE      ORI for unit with imputed or actual NIBRS records
                         ORI             ORI for imputation donor (for use in merging with NIBRS files)
                         STRATUM         Stratum number for ORI_SAMPLE
                         LEA_WT          Sampling weights for units in LEA sample 
                         IMPUTEFLAG      = 1 IF IMPUTED, 0 IF NOT IMPUTED
                         and variables from hierarchical incident file OFFENSEH */
);

 /* CREATES INCIDENT FILE (HIERARCHICAL FORMAT) WITH &NUM_IMPUTE IMPUTATIONS FOR NIBRS NONREPORTERS  */


 %DO IMP_NUM = 1 %TO &NUM_IMPUTE;


    %LET SEED_IMP = %EVAL(&SEED_START + %EVAL(15000*(&IMP_NUM-1)));
    %PUT &SEED_IMP;

    %IMPUTE_SAMPLE(
      LEA_COUNTS     =   &LEA_COUNTS /* Input  Name of dataset giving SRS incident counts for sampled NIBRS nonreporters in long format */
     ,BASE_DATA      =   &BASE_DATA /* Input  Name of dataset giving incidents (hierarchical) for full NIBRS reporters */
     ,DONORSET       =   &DONORSET /* Input  Name of dataset to be used to obtain incidents for hot deck donors */
     ,SEED_IMPUTE    =   &SEED_IMP /* Input  Random number seed to use for starting the imputation */
     ,OUTDATA        =   _IMPUTED_DATA /* Output Name of output data file containing imputed crime incidents */                    
);

  DATA _IMPUTED_DATA;
     SET _IMPUTED_DATA;
     _IMPUTATION_ = &IMP_NUM;
  RUN;

  %IF &IMP_NUM = 1 %THEN %DO;
	 DATA &M_IMPUTE_FILE;
	 SET _IMPUTED_DATA;
	 RUN;
  %END; /* IF &IMP_NUM = 1 */

  % ELSE %DO;
   DATA &M_IMPUTE_FILE;
      SET &M_IMPUTE_FILE _IMPUTED_DATA;
   RUN;
  %END; /* IF IMP_NUM = 1 ELSE */

 %END; /* ITERATION OVER &IMP_NUM */

%MEND MULTIPLE_IMPUTE;


/**************VERSION OF MULTIPLE IMPUTATION THAT SETS MOS FOR PHX, TUCSON EACH TIME ***********************/
%MACRO MULTIPLE_IMPUTE_MOS(
   LEA_COUNTS     =   /* Input  Name of dataset giving SRS incident counts for NIBRS nonreporters, wide format.
                                Must have columns with same names as HIER_OFFs in DONORSET  */
  ,NUM_IMPUTE     =   /* Input  Number of imputed datasets to be formed */
  ,MOS_EXTRA      =   /* Input  Name of dataset giving MOS's for ORIs where these vary across imputations
                                Must contain variables
                                   YEAR = year of data for imputation donors
                                   ORI  = ORI of imputation donors
                                   IMPUTE_NUM ranging from 1 to &NUM_IMPUTE
                                   MOS_*  columns giving MOS's for sampled ORIs to be imputed */
  ,BASE_DATA      =   /* Input  Name of dataset giving incidents (hierarchical) for full NIBRS reporters */
  ,DONORSET       =   /* Input  Name of dataset to be used to obtain incidents for hot deck donors */
  ,SEED_START     =   /* Input  Random number seed to use for starting the imputation */
  ,M_IMPUTE_FILE  =   /* Output Name of output data file containing multiply imputed crime incidents */
                      /* Contains variables
                         _IMPUTATION_    Imputation number
                         ORI_SAMPLE      ORI for unit with imputed or actual NIBRS records
                         ORI             ORI for imputation donor (for use in merging with NIBRS victim, offender files)
                         STRATUM         Stratum number for ORI_SAMPLE
                         LEA_WT          Sampling weights for units in LEA sample 
                         IMPUTEFLAG      = 1 IF IMPUTED, 0 IF NOT IMPUTED
                         and variables from hierarchical incident file OFFENSEH */
);

 /* CREATES INCIDENT FILE (HIERARCHICAL FORMAT) WITH &NUM_IMPUTE IMPUTATIONS FOR NIBRS NONREPORTERS  */

 %DO IMP_NUM = 1 %TO &NUM_IMPUTE;

   /* MERGE MOS'S FOR CITIES WHERE MOS VARIES WITH EACH IMPUTATION */

   DATA _MOS_NEEDED_IMP (DROP = IMPUTE_NUM);
      SET &MOS_EXTRA;
      IF IMPUTE_NUM = &IMP_NUM;
   RUN;

   PROC SORT DATA=_MOS_NEEDED_IMP;
      BY YEAR ORI;
   PROC SORT DATA=&DONORSET;
      BY YEAR ORI;

  PROC SQL;
   SELECT NAME INTO :_MOS_VARY_LIST SEPARATED BY " " 
     FROM DICTIONARY.COLUMNS
     WHERE LIBNAME = 'WORK' AND MEMNAME = "_MOS_NEEDED_IMP" AND UPCASE(NAME) LIKE 'MOS%';
  QUIT;

   DATA _DONOR_IMPUTE;
     MERGE &DONORSET(DROP = &_MOS_VARY_LIST) _MOS_NEEDED_IMP;
     BY YEAR ORI;
   RUN;

    %LET SEED_IMP = %EVAL(&SEED_START + %EVAL(15000*(&IMP_NUM-1)));
    %PUT &SEED_IMP;

    %IMPUTE_SAMPLE(
      LEA_COUNTS     =   &LEA_COUNTS 
     ,BASE_DATA      =   &BASE_DATA 
     ,DONORSET       =   _DONOR_IMPUTE /* Input  Name of dataset to be used to obtain incidents for hot deck donors */
     ,SEED_IMPUTE    =   &SEED_IMP /* Input  Random number seed to use for starting the imputation */
     ,OUTDATA        =   _IMPUTED_DATA /* Output Name of output data file containing imputed crime incidents */                    
);

  DATA _IMPUTED_DATA;
     SET _IMPUTED_DATA;
     _IMPUTATION_ = &IMP_NUM;
  RUN;

  %IF &IMP_NUM = 1 %THEN %DO;
	 DATA &M_IMPUTE_FILE;
	 SET _IMPUTED_DATA;
	 RUN;
  %END; /* IF &IMP_NUM = 1 */
  % ELSE %DO;
   DATA &M_IMPUTE_FILE;
      SET &M_IMPUTE_FILE _IMPUTED_DATA;
   RUN;
  %END; /* IF IMP_NUM = 1 ELSE */

 %END; /* ITERATION OVER &IMP_NUM */


%MEND MULTIPLE_IMPUTE_MOS;


%MACRO MERGE_IMPUTED_FILES(
   HIER_FILE      =   /* Input  Name of dataset with multiply imputed hierarchically ordered offenses  */
  ,MERGE_FILE     =   /* Input  Name of dataset to be merged */
  ,MERGED_IMPUTE  =   /* Output Name of merged output data file containing imputed crime characteristics */
                      /* Contains the following variables from &HIER_FILE
                         _IMPUTATION_    Imputation number
                         ORI_SAMPLE      ORI for unit with imputed or actual NIBRS records
                         STRATUM         Stratum number for ORI_SAMPLE
                         LEA_WT          Sampling weights for units in LEA sample 
                         IMPUTEFLAG      = 1 IF IMPUTED, 0 IF NOT IMPUTED
                         and variables from hierarchical incident file OFFENSEH */
);

 /* MERGES THE MULTIPLY IMPUTED HIERARCHICAL OFFENSE FILE WITH THE NIBRS OFFENSE, VICTIM,
    OFFENDER, AND PROPERTY FILES. KEEP ONLY RECORDS THAT ARE IN &HIER_FILE */

PROC SQL NOPRINT;
   CREATE TABLE &MERGED_IMPUTE AS
   SELECT ONE.ORI_SAMPLE, ONE.STRATUM, ONE.LEA_WT, ONE._IMPUTATION_, ONE.IMPUTE_FLAG, TWO.*
   FROM &HIER_FILE AS ONE
   LEFT JOIN &MERGE_FILE AS TWO
      ON (ONE.YEAR = TWO.YEAR AND
          ONE.ORI = TWO.ORI AND 
          ONE.INCIDENT_NUMBER = TWO.INCIDENT_NUMBER)
	;
QUIT;

%MEND MERGE_IMPUTED_FILES;


/* ********************* MACRO TO GET MEASURES OF SIZE FOR IMPUTATIONS ************************ */


%MACRO MOS_CALC(
   CITY           =   /* Input  Name of dataset giving demographic information of city for which MOS is desired.
                                Must contain column named ORI, giving ORI for the city's LEA.
                                Must have columns of demographic counts with same names as in DONOR_DEMOG  */
  ,DONOR_DEMOG    =   /* Input  Name of dataset giving demographic information of potential donor cities.
                                Rows are the donor cities, columns are variables giving demographic counts.
                                Must contain column named ORI, giving ORI for the city's LEA. */
  ,MATCHLIST      =   /* Input  List of variables for which matching is desired. */
  ,REL_IMP        = 0 /* Input  Specifies rule for relative importance of variables used for matching.
                                Function minimizes e'Qe subject to x>= 0 and Ax + e = b. 
                                REL_IMP = 0 sets Q = diag(1); all components treated equally. 
                                REL_IMP = J sets Q = 1000 for first J elements in MATCHLIST, 1 for other items.
                                REL_IMP = 99 sets Q = 1000 *diag(1/(b + 1)); gives higher penalty for smaller counts */
  ,UPPERBOUND     = 1 /* Input  Upper bound on MOS (scalar). */
  ,SEED           = 1 /* Seed for random number generator to give initial value of x. */
  ,SOLNDATA       =   /* Output Name of output data file containing relative measures of size for imputations */
                      /* Contains variable
                         MOS_&ORI        Relative weights of donor cities on variables in &MATCHLIST,
                                         with one row for each donor city */

  ,ERRORDATA      =   /* Output Name of output data file containing errors e when fitting Ax + e = b */
                      /* Contains variable
                         ERROR_&ORI      Errors on variables in &MATCHLIST,
                                         with one row for each variable */
);

  /* Gets the measure of size for one city and set of demographic variables.
     Let A' = matrix of demographic information from DONOR_DEMOG, b' = row vector of demographic info from CITY.
     Uses quadratic programming to solve Ax + e = b while minimizing e'Qe and constraining 0 <= x <= UPPERBOUND.
     Solution vector x  */

PROC IML;
  /* Uses quadratic programming to solve Ax + e = b while minimizing e'Qe */
  use &DONOR_DEMOG;
      varNames = {&MATCHLIST};
	  read all var varNames into Atr [colname = varnames];
	  read all var {placename} into PLACENAME;
	  read all var {ORI} into ORI;
  close &DONOR_DEMOG; 
  A = Atr`;
  mattrib A colname = placename;
  
  use &CITY;
      varNames = {&MATCHLIST};
	  read all var varNames into Btr [colname = varnames];
	  read all var {placename} into CITYNAME;
	  read all var {ORI} into CITY_ORI;
  close &CITY;   
  bvec = Btr`;

  n_conditions = nrow(A);
  n_cities = ncol(A);

  A_aug = A || I(n_conditions);
  errorcolstart = n_cities + 1;
  errorcolend = ncol(A_aug);

 /* set random initial value for x so that 0 <= x_i <= upperbound and \sum_i A[1,i] x_i = b_1.
    Add n_conditions rows of 0 to set initial values for epsilons (which are desired to be close to 0).
    Note that generating x ~ Unif(0,1) and setting x_init = x/sum(x) does not give values uniformly
    distd in set since they tend to be clustered in center --- results in too little variability.
    Instead, we generate initial values from a flat Dirichlet distribution that satisfy the first constraint,
    truncating to &UPPERBOUND.  */

  call randseed(&SEED);
  z_init = RandDirichlet(1,J(1,n_cities,1));
  z_init = z_init||(1-sum(z_init));
  x_init = bvec[1]*z_init`;
  do j = 1 to n_cities;
     if A[1,j] > 1e-6 then x_init[j] = x_init[j]/A[1,j];
	 else x_init[j] = 0;
  end;
  x_init = x_init >< &UPPERBOUND;
  x_init = x_init//J(n_conditions,1,0);

  /* specify Q matrix = diag(0,I) if &relwgt = 0
                      proportional to 1/bvec if &relwgt = 1 to give more accuracy for smaller groups */
  Q = block(J(ncol(A),ncol(A),0),I(n_conditions));
  if &rel_imp >=1 then do;
     do indx = 1 to &rel_imp;
        Q[ncol(A)+indx,ncol(A)+indx] = 1000;
     end;
  end;
  if &rel_imp = 99 then Q = block( J(ncol(A),ncol(A),0),1000*diag(1/(bvec + 1)) );

 /* set linear term of objective function to 0 */
  linvec = J(ncol(A_aug),1,0);

 /* set lower, upper bounds for x*/
  lb = J(1,ncol(A),0) ||J(1,ncol(A_aug)-ncol(A)+2,.);
  ub = J(1,ncol(A),&UPPERBOUND) ||J(1,ncol(A_aug)-ncol(A)+2,.);
  bounds = lb//ub;

  /* set linear constraints */

  lc1 = A_aug || J(nrow(A_aug),1,0);
  lc = lc1 || bvec; /* lc has linear constraints A_aug x + e = b */
  constr = bounds//lc;

  options = {0 2}; /* minimize quadratic, print */

  call NLPQUA(rc,xr,Q,x_init,options,constr,, , , linvec);

  mattrib xr colname = placename;

  /* set soln to be the elementwise maximum of xr and 0 (sometimes roundoff error leads to value < 0) */
  soln = xr[1,1:n_cities]` <> 0;
  error =xr[1,errorcolstart:errorcolend]`;

  mos_name = concat("MOS_",CITY_ORI);
  ORIlabel = "ORI";
  mycolname = ORIlabel ||mos_name;

  create &SOLNDATA from ORI soln [colname=mycolname];
     append from ORI soln;
  close;

  create &ERRORDATA from error[colname=CITY_ORI];
     append from error;
  close;

quit;

%MEND MOS_CALC;


%MACRO CALCULATE_MOS(
   INDATA=         /* Input: Name of dataset containing the ORI where MOS is needed and its demo info
                      Must contain variables 
                      IMPUTE_NUM   Number of imputation to be used
                      ORI          ORI for which matching is desired 
                      MATCHVARS    String variable (length 300) listing variables to be used for matching 
                      Demographic variables corresponding to the list in MATCHVARS */ 
  ,DONORFILE=      /* Input: Name of dataset containing ORIs and demographic info for donor ORIs */
  ,REL_IMP=    1   /* Input  Specifies rule for relative importance of variables used for matching.
                                Function minimizes e'Qe subject to x>= 0 and Ax + e = b. 
                                REL_IMP = 1 sets Q = diag(1); all components treated equally. 
                                REL_IMP = 2 sets Q = 1000 *diag(1/(b + 1)); gives higher penalty for smaller counts */
  ,UPPERBOUND= 1   /* Input  Upper bound on MOS (scalar). */
  ,STARTSEED=  1   /* Input  Starting seed for random number generator */
  ,SOLN =          /* Output Name of output data file containing relative measures of size for imputations */
                   /* Variables 
                         IMPUTE_NUM  	 Set number for the set of matching variables used
                         ORI             ORI for the donor ORI used in the match
                         MOS_**          Relative weights of donor cities on variables in &MATCHLIST,
                                         with one column for each ORI in INDATA */
  ,ERROR=          /* Output Name of output data file containing errors e in solution to Ax + e = b */
);

/* Calculates MOS for a dataset INDATA containing the list of variables to be matched */

%LET DSID     = %SYSFUNC(OPEN(WORK.&INDATA));
%LET NOBS     = %SYSFUNC(ATTRN(&DSID,NLOBS));
%LET RC       = %SYSFUNC(CLOSE(&DSID));
%PUT &NOBS;

%DO J = 1 %TO &NOBS;

/* CREATE DATASET FOR JTH SET OF MATCHING VARIABLES */
DATA _INDATA_ITER;
   SET &INDATA (FIRSTOBS = &J OBS = &J);
   CALL SYMPUT('MATCHVAR_LIST',MATCHVARS);
RUN;

%PUT &MATCHVAR_LIST;
%LET NUM_MATCHVARS = %sysfunc(countw(&MATCHVAR_LIST));
%PUT &NUM_MATCHVARS;

DATA _MERGE_IMPUTENUM (KEEP = SAMPLE_ORI IMPUTE_NUM MATCHVARS);
   SET _INDATA_ITER;
   SAMPLE_ORI = ORI;
RUN;

DATA _MERGE_MATCHVARS (DROP = OBS);
   LENGTH MATCHVAR $ 20;
   DO OBS = 1 TO &NUM_MATCHVARS;
      MATCHVAR = SCAN("&MATCHVAR_LIST",OBS);
      OUTPUT;
   END;


%LET _SEEDITER = %EVAL(&STARTSEED + %EVAL(&J-1)) ;
%put &_seediter;


%MOS_CALC(
   CITY           =  _INDATA_ITER 
  ,DONOR_DEMOG    =  &DONORFILE 
  ,MATCHLIST      =  &MATCHVAR_LIST 
  ,REL_IMP        =  &REL_IMP
  ,UPPERBOUND     =  1 
  ,SEED           =  &_SEEDITER 
  ,SOLNDATA       =  _MYSOLN 
  ,ERRORDATA      =  _MYERROR 
);

DATA _MYSOLN;
	 IF _N_ = 1 THEN DO;
	    SET _MERGE_IMPUTENUM (KEEP = IMPUTE_NUM);
	 END;
   SET _MYSOLN;

DATA _MYERROR;
	 IF _N_ = 1 THEN DO;
	    SET _MERGE_IMPUTENUM;
	 END;
   MERGE _MERGE_MATCHVARS _MYERROR;
RUN;

%IF &J = 1 %THEN %DO;
 DATA &SOLN ;
   SET _MYSOLN;
 DATA &ERROR ;
   SET _MYERROR;
%END; /* IF J = 1  */
%ELSE %DO;
  DATA &SOLN;
    SET &SOLN _MYSOLN;
  DATA &ERROR;
    SET &ERROR _MYERROR;
%END; /* ELSE */
   
%END; /* ITERATION OVER J LOOP */

%MEND CALCULATE_MOS;



