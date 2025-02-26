Multidimensional Deprivation Index
**************************************************************************************************************
** Objective: Construction of the Multidimensional Deprivation Index (MDDI) based on the codebook questions prepared for the MDDI module 
/* https://docs.wfp.org/api/documents/WFP-0000121341/download/


/**Creation of variables of deprivations for each dimension
***MDDI: Food Dimension

***Food Consumption Score***
***Define labels 
FCSStap           Consumption over the past 7 days (cereals and tubers)
FCSVeg            Consumption over the past 7 days (vegetables)
FCSFruit           Consumption over the past 7 days (fruit)
FCSPr              Consumption over the past 7 days (protein-rich foods)
FCSPulse         Consumption over the past 7 days (pulses)
FCSDairy          Consumption over the past 7 days (dairy products)
FCSFat             Consumption over the past 7 days (oil)
FCSSugar         Consumption over the past 7 days (sugar)


compute FCS = sum(FCSStap*2, FCSVeg, FCSFruit, FCSPr*4, FCSPulse*3, FCSDairy*4, FCSFat*0.5, FCSSugar*0.5).
variable labels FCS "Food Consumption Score".
execute.

***Use this when analyzing a country with high consumption of sugar and oil – thresholds 28-42

recode FCS (0 thru 28 =1) (28 thru 42 =2) (42 thru highest =3) into FCSCat28.
variable labels FCSCat28 "FCS Categories".
execute.
 
***Use this when analyzing a country with low consumption of sugar and oil - thresholds 21-35

recode FCS (0 thru 21 =1) (21 thru 35 =2) (35 thru highest =3) into FCSCat21.
variable labels FCSCat21 "FCS Categories".
execute.

***Define variables labels and properties for "FCS Categories"

value labels FCSCat21
 1.00 'poor'
 2.00 'borderline'
 3.00 'acceptable '.

value labels FCSCat28
 1.00 'poor'
 2.00 'borderline'
 3.00 'acceptable '.
execute.

frequencies FCSCat21 FCSCat28.

*Turn into MDDI variable (with high consumption of sugar and oil countries)
/*** Note: Construct the same indicators with different threshold (21) for low consumption of sugar and oil countries
    
if (FCSCat28=1 | FCSCat28=2) MDDI_food1=1.
recode MDDI_food1 (sysmis=0).
execute.
frequencies MDDI_food1.
Variable labels MDDI_food1 ‘Percentage of HH with unacceptable food consumption’.

/**rCSI (Reduced Consumption Strategies Index***
    
/***Variable labels 
/*1. Relied on less preferred, less expensive food *1-rCSILessQlty
/*2. Borrowed food or relied on help from friends or relatives*2-rCSIBorrow
/*3. Reduced the number of meals eaten per day*1 - rCSIMealNb
/*4. Reduced portion size of meals at meals time *1-rCSIMealSize
/*5. Restrict consumption by adults in order for young-children to eat*3-rCSIMealAdult


compute rCSI=(rCSILessQlty * 1) + (rCSIBorrow* 2) + (rCSIMealNb * 1) + (rCSIMealSize * 3) + (rCSIMealAdult * 1).
execute.

/*For the rCSI, use the threshold as 18 - this is defined as IPC3+
    
if ( rCSI >18 ) MDDI_food2=1.
recode MDDI_food2 (sysmis=0).
execute.

Variable labels MDDI_food2 ‘Percentage of HH with high level of consumption coping strategies’.
frequencies MDDI_food2.

***MDDI: Education dimension
  
/*At least one school age children (6-17) (Adjust to country context) not attending school in the last 6 months 
   
if (HHNoSchoolAttNb_6M > 0 ) MDDI_edu=1.
recode MDDI_edu (sysmis=0).
execute.

Variable labels MDDI_edu ‘Households with at least one school-age children not attending school’.
frequencies MDDI_edu.

***MDDI: Health
    
/*First indicator : Medical treatment - Did household members being chronically or acutely ill receive medical attention while sick? (answers - 0= No 1=Yes, some of them 2=Yes, all of them)
      
if ( HHENHealthMed=0 |  HHENHealthMed=1) MDDI_health1=1.
recode MDDI_health1 (sysmis=0).
execute.
Variable labels MDDI_health1 ‘At least one member did not reeive medical treatment while sick’.
Frequencies MDDI_health1.

/*Second indicator: Number of sick people > 1 or >50% of household members   
/****Add both disabled and chronically ill members
    
compute HHSickNb= sum(HHDisabledNb, HHChronIllNb).
compute HHSickShare= HHSickNb/ HHSize.
if (HHSickNb > 1 | HHSickShare > 0.5) MDDI_health2=1.
recode MDDI_health2 (sysmis=0).
execute.
Variable labels MDDI_health2 ‘HH with more than half members or at least one member sick’.
Frequencies MDDI_health2.

***MDDI: Shelter
    
/*First Indicator: Source of energy for cooking - for MDDI calculation make sure to distinguish between solid and non-solid fuels.

if ( HEnerCookSRC=0 | HEnerCookSRC=100 | HEnerCookSRC=200 | HEnerCookSRC=500 | HEnerCookSRC=600 | HEnerCookSRC=900 | HEnerCookSRC=999) MDDI_shelter1=1.
recode MDDI_shelter1 (sysmis=0).
execute.
Variable labels MDDI_shelter1 ‘ Households with no improved energy source for cooking’.
Frequencies MDDI_shelter1.

/*Second Indicator: Source of energy for lighting - HH has no electricity
    
if ( HEnerLightSRC=401 | HEnerLightSRC=402) MDDI_shelter2=0.
recode MDDI_shelter2 (sysmis=1).
execute.
Variable labels MDDI_shelter2 ‘Households with no  improved source of energy for lighting’.
Execute.
Frequencies MDDI_shelter2.

/*Third Indicator: Crowding Index  ( Number of HH members/Number of rooms (excluding kitchen, corridors)) >3 
    
compute crowding= HHSize/HHRoomUsed.
if ( crowding > 3) MDDI_shelter3=1.
recode MDDI_shelter3 (sysmis=0).
execute.
Variable labels MDDI_shelter3 ‘Households with at least 3 HH members sharing one room to sleep’.
    
****MDDI: WASH 
    
/*First Indicator: Toilet Type (not-improved facility)
    
if ( HToiletType=20100 | HToiletType=20200 | HToiletType=20300 | HToiletType=20400 | HToiletType=20500) MDDI_wash1=1.
recode MDDI_wash1 (sysmis=0).
execute.
Variable labels MDDI_wash1 ‘Households with not improved toilet facility’.
Frequencies MDDI_wash1.
    
/*Second Indicator: Water source (not-improved facility)
    
if ( HWaterSRC=500 | HWaterSRC=600 | HWaterSRC=700 | HWaterSRC=800) MDDI_wash2=1.
recode MDDI_wash2 (sysmis=0).
execute.
Variable labels MDDI_wash2 ‘Households with not improved facility for drinking water source’.
Frequencies MDDI_wash2.
    

***MDDI: Safety

/*First Indicator: Safety : Felt unsafe or suffered violence
    
if ( HHPercSafe=0) MDDI_safety1=1.
recode MDDI_safety1 (sysmis=0).
execute.
Variable labels MDDI_safety1 ‘One or more HH members felt unsafe or suffered violence’.
Frequencies MDDI_safety1.

/*Second Indicator: Displaced by forced in the last 12 months (calculate a new variable for arrivals within the last 12 months)
/***Example of calculating the arrival time by months ( adjust if you already have a variable for the date of data collection and use it instead of ‘today’ variable)

*****Step 1. Create current date as new variable in data

compute today = $time.
execute.

******Step 2. Show current date in date format

formats today HHHDisplArrive  (edate10).

******Step 3. Compute the difference

compute Arrival_time = datediff(today, HHHDisplArrive,'months').
execute.

*****Step 4. Don't show any decimal places

formats Arrival_time (f4).

****Step 5. Calculate if arrival time is less than 12 months
    
if (Arrival_time < 13) MDDI_safety2=1.
recode MDDI_safety2 (sysmis=0).
execute.
frequencies MDDI_safety2.
Variable labels MDDI_safety2 ‘HH has been displaced in the last 12 months’.

****Finalize the calculation of final MDDI**
    
/*Deprivations for each category
/**Weighting : Method of nesting with equal weights 
/***Calculate the overall deprivation score of each dimension, we can use it to have a spider chart to show overall percentage of deprivation for each dimension
    
compute MDDI_food= (MDDI_food1*1/2)+ (MDDI_food2*1/2).
compute MDDI_edu=MDDI_edu*1.
compute MDDI_health= (MDDI_health1*1/2)+ (MDDI_health2*1/2).
compute MDDI_shelter=(MDDI_shelter1*1/3)+(MDDI_shelter2*1/3)+ (MDDI_shelter3*1/3).
compute MDDI_wash=(MDDI_wash1*1/2) + (MDDI_wash2*1/2).
compute MDDI_safety= (MDDI_safety1*1/2) + (MDDI_safety2*1/2).
execute.
Variable labels 
MDDI_food ‘Deprivation score for food dimension’
MDDI_edu ‘Deprivation score for education dimension’
MDDI_health ‘Deprivation score for health dimension’
MDDI_shelter ‘Deprivation score for shelter dimension’
MDDI_wash ‘Deprivation score for WASH dimension’
MDDI_safety ‘Deprivation score for safety and displacement dimension’.
Execute.
frequencies MDDI_food MDDI_edu MDDI_health MDDI_shelter MDDI_wash MDDI_safety.

/*Final MDDI Calculations
/**Calculate the Overall MDDI Score

compute MDDI=sum(MDDI_food, MDDI_edu, MDDI_health, MDDI_shelter, MDDI_wash, MDDI_safety)/6.
execute.
Variable labels MDDI ‘MDDI score’.
frequencies MDDI.

/***Calculate MDDI Incidence (H)
/***Thresholds are 0.50 for severe deprivation and 0.33 for deprivation – it can be adjusted according to the context

if (MDDI GE 0.50) MDDI_poor_severe=1.
if (MDDI GE 0.33) MDDI_poor=1.
recode MDDI_poor MDDI_poor_severe (sysmis=0).
execute.
Variable labels MDDI_poor ‘MDDI Incidence’.
Variable labels MDDI_poor_severe ‘MDDI Incidence – severe deprivation’.
Value labels MDDI_poor MDDI_poor_severe 
	 1 ‘ HH is deprived’
                   0 ‘HH is not deprived’.
Execute.
/**Calculate the Average MDDI Intensity (A)

If (MDDI_poor=1) MDDI_intensity=MDDI.
variable labels MDDI_intensity 'Average MDDI Intensity (A)'.
execute.
frequencies MDDI_intensity.


/***Calculate Combined MDDI (M= HxA)

Compute MDDI_combined=MDDI_poor*MDDI_intensity.
Variable labels MDDI_combined ‘Combined MDDI (M)’.
Execute.
/**Show results 

frequencies MDDI_poor MDDI_poor_severe.
frequencies MDDI_intensity MDDI_combined /histogram /statistics.


