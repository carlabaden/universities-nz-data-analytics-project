/****************************************************************************************************
 * Otago 2019–2022
 ****************************************************************************************************/
%inputfiles("&path./datasets/raw/_OTAGO_2019-2022.xlsx", xlsx, ota_raw_2019_2022);

data ota_temp_2019_2022;
    set ota_raw_2019_2022;

    length 
        Uni_name         $36.
        Pub_ISBN_ISSN    $36.
        Course_code2     $16.
        Pub_place        $48.
        Pub_publisher    $128.;

    Uni_name       = "University of Otago";
    Pub_ISBN_ISSN  = "ISBN/ISSN"n;
    Course_code2   = Course_code_clean;
    Pub_place      = Place;
    Pub_publisher  = Publisher;

    rename 
        Year                = Academic_Year
        Course_NFS          = Course_NFOS
        Date_of_Publication = Pub_year
        Major_Material_type = Pub_material_type_maj
        Student_Numbers     = Course_enr_num;

    keep 
        Year Uni_name Course_code2 Course_BFOS Course_NFS Student_Numbers Pub_ISBN_ISSN 
        Date_of_Publication Pub_place Pub_publisher Major_Material_type Amount_copied;
run;


/****************************************************************************************************
 * Otago 2023 & 2024
 ****************************************************************************************************/
%inputfiles("&path./datasets/raw/OTA_2023.xlsx", xlsx, ota_raw_2023);
%inputfiles("&path./datasets/raw/OTA_2024.xlsx", xlsx, ota_raw_2024);

/* Merge Otago 2023 & 2024 data */
data ota_temp_2023_2024;
    set 
        ota_raw_2023 (in=a)
        ota_raw_2024 (in=b);
    if a then do; end;
    if b then do; end;
run;

proc contents data=ota_temp_2023_2024;
run;

data ota_temp_2023_2024;
    set ota_temp_2023_2024;

    length 
        Uni_name       $36.
        Pub_ISBN_ISSN  $36.
        Course_code2   $16.
        Pub_place      $48.
        Pub_publisher  $128.;

    Uni_name       = "University of Otago";
    Pub_ISBN_ISSN  = "ISBN/ISSN"n;
    Course_code2   = Course_code_clean;
    Pub_place      = Place;
    Pub_publisher  = Publisher;

    rename 
        Year                = Academic_Year
        Date_of_Publication = Pub_year
        Major_Material_type = Pub_material_type_maj
        Student_Numbers     = Course_enr_num;

    keep 
        Year Uni_name Course_code2 Student_Numbers Pub_ISBN_ISSN Date_of_Publication 
        Pub_place Pub_publisher Major_Material_type Minor_Material_Type Amount_copied;
run;


/*-----------------------------------------------------------------------------------------------*
 * Attach BFOS and NFOS using lookup table
 *-----------------------------------------------------------------------------------------------*/
%inputfiles("&path./datasets/raw/BFOS_NFOS.xlsx", xlsx, BFOS_NFOS_temp);

proc sql;
    create table otago_2023_2024_with_BFOS as 
    select 
        a.*, 
        b.BroadFieldName  as Course_BFOS, 
        b.NarrowFieldName as Course_NFOS 
    from 
        ota_temp_2023_2024 a 
    left join 
        (select * from BFOS_NFOS_temp where ProviderCode = 7007) b
    on 
        a.Course_code2 = b.CourseCode;
quit;

/* Check for missing BFOS */
proc freq data=otago_2023_2024_with_BFOS;
    where Course_BFOS = "" or Course_BFOS = "Unknown"; 
    tables Course_code2;
run;


/*-----------------------------------------------------------------------------------------------*
 * Override missing BFOS and NFOS
 *-----------------------------------------------------------------------------------------------*/
data otago_2023_2024_with_BFOS;
    set otago_2023_2024_with_BFOS;

    if Course_code2 = 'ACCT222' then do; Course_BFOS = 'Management and Commerce'; Course_NFOS = 'Accountancy'; end;
    if Course_code2 = 'ANTH312' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Studies in Human Society'; end;
    if Course_code2 = 'CELS191' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Human Welfare Studies and Services'; end;
    if Course_code2 = 'CHTH131' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'ECON206' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Studies in Human Society'; end;
    if Course_code2 = 'ECON303' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Studies in Human Society'; end;
    if Course_code2 = 'ENGL127' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'ENGL233' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'ENTR101' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Studies in Human Society'; end;
    if Course_code2 = 'GEOG102' then do; Course_BFOS = 'Natural and Physical Sciences'; Course_NFOS = 'Mathematical Sciences'; end;
    if Course_code2 = 'INDS301' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'INDS302' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'INDS307' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'MAOR327' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Studies in Human Society'; end;
    if Course_code2 = 'MFCO212' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'MICN301' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Language and Literature'; end;
    if Course_code2 = 'MUSI270' then do; Course_BFOS = 'Health'; Course_NFOS = 'Medical Studies'; end;
    if Course_code2 = 'PHTY539' then do; Course_BFOS = 'Health'; Course_NFOS = 'Public Health'; end;
    if Course_code2 = 'PHTY543' then do; Course_BFOS = 'Health'; Course_NFOS = 'Public Health'; end;
    if Course_code2 = 'POLS550' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Political Science and Policy Studies'; end;
    if Course_code2 = 'PSYC204' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Philosophy and Religious Studies'; end;
    if Course_code2 = 'RELS235' then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Philosophy and Religious Studies'; end;
    if Course_code2 = 'EDDC9'   then do; Course_BFOS = 'Education'; Course_NFOS = 'Teacher Education'; end;
    if Course_code2 = 'LAWS'    then do; Course_BFOS = 'Society and Culture'; Course_NFOS = 'Law'; end;
    if Course_code2 = 'MICN6'   then do; Course_BFOS = 'Health'; Course_NFOS = 'Medical Studies'; end;
    if Course_code2 = 'PSYC400' then do; Course_BFOS = 'Behavioural Science'; Course_NFOS = 'Law'; end;
    if Course_code2 = 'SPEX400' then do; Course_BFOS = 'Health'; Course_NFOS = 'Other Health'; end;
run;


/****************************************************************************************************
 * Merge Otago 2019–2022 & Otago 2023–2024
 ****************************************************************************************************/
data ota_temp_2019_2024;
    set 
        otago_2023_2024_with_BFOS 
        ota_temp_2019_2022;
run;

/****************************************************************************************************
 * Standardise Major Material Types
 ****************************************************************************************************/
%material_maj(ota_temp_2019_2024, ota_temp_2019_2024);

proc freq data=ota_temp_2019_2024;
    tables Academic_Year * Pub_material_type_maj / nocol norow nopercent nocum missing;
run;

/****************************************************************************************************
 * Determine NZ Place and Publisher
 ****************************************************************************************************/

/* add pub_country and pub_city columns */
%NZ_pub_step1(ota_temp_2019_2024, ota_temp_2019_2024);

%NZ_pub_step2(ota_temp_2019_2024, ota_temp_2019_2024);

/* Check application of NZ_pub macro */
proc freq data=ota_temp_2019_2024;
    where NZ_publisher = 1;
    tables Academic_Year * NZ_publisher / nocol norow nopercent;
run;

proc freq data=ota_temp_2019_2024;
    where Uni_press = 1;
    tables Academic_Year * Uni_press / nocol norow nopercent;
run;

proc freq data=ota_temp_2019_2024;
    where NZ_place_publication = 1;
    tables Academic_Year / nocol norow nopercent missing;
run;

proc freq data=ota_temp_2019_2024;
    tables NZ_place*Academic_Year / nocol norow nopercent missing;
run;

proc freq data=ota_temp_2019_2024;
	where Uni_press = 1;
    tables Pub_publisher*Academic_Year / nocol norow nopercent missing;
run;

proc freq data=ota_temp_2019_2024;
	where Pub_country = 'New Zealand';
    tables Pub_place / nocol norow nopercent missing;
run;
