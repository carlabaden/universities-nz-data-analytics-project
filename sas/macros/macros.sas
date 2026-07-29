/* read .xlsx files */
%macro inputfiles(INPUT, FILETYPE, name);
	FILENAME REFFILE &INPUT;

	PROC IMPORT DATAFILE=REFFILE DBMS=&FILETYPE
	OUT=WORK.&name replace;
		Guessingrows=20000;
		GETNAMES=YES;
	RUN;
%mend;

/* Standardise major material types */
%macro material_maj(input, output);
data &output;
	set &input;
	
	if Pub_material_type_maj in ('Conference', 'Document', 'Proceeding', 'Report', 'other', 'score', 'website')
			then Pub_material_type_maj = 'Other';
		else if Pub_material_type_maj in ('Manuscript', 'Whole Journal', 'periodical/journal')
			then Pub_material_type_maj = 'Periodical/journal';
		else if Pub_material_type_maj in ('Whole Book', 'book')
			then Pub_material_type_maj = 'Book';
		else if Pub_material_type_maj = 'newspaper'
			then Pub_material_type_maj = 'Newspaper';
			
	Pub_place = tranwrd(trim(Pub_place), "_", ",");
	Pub_publisher = tranwrd(trim(Pub_publisher), "_", ",");
	course_nfos = tranwrd(trim(course_nfos), "_", ",");
	
	run;
	
			proc freq data=conzul_temp2;
			table course_bfos course_nfos Pub_material_type_maj;
			run;
			
	proc export data=conzul_temp2 replace
	    outfile="&path./outputs/CONZUL_TEMP2.csv"
	    dbms=csv;
	run;
	
%mend;

/* Make pub country and pub city columns (previously done manually in excel) */
%macro NZ_pub_step1(input, output);
data &output;
    set &input;

    length Pub_country $20 Pub_city $20;

    /* Convert to uppercase */
    up_pub_place = upcase(Pub_place);

    if index(up_pub_place, 'NZ') > 0 or
       index(up_pub_place, 'N.Z') > 0 or
       index(up_pub_place, 'N.Z.') > 0 or
       index(up_pub_place, '[N.Z.]') > 0 or
       index(up_pub_place, 'AOTEAROA') > 0 or
       index(up_pub_place, 'NEWZEALAND') > 0 or
       index(up_pub_place, 'NEW ZEALAND') > 0 or
       index(up_pub_place, 'AUCKLAND') > 0 or
       index(up_pub_place, 'BLENHEIM') > 0 or
       index(up_pub_place, 'CAMBRIDGE, NZ') > 0 or
       index(up_pub_place, 'CHRISTCHURCH') > 0 or
       index(up_pub_place, 'DUNEDIN') > 0 or
       index(up_pub_place, 'HAMILTON') > 0 or
       index(up_pub_place, 'LINCOLN, NZ') > 0 or
       index(up_pub_place, 'MASTERTON') > 0 or
       index(up_pub_place, 'NELSON') > 0 or
       index(up_pub_place, 'OTAKI') > 0 or
       index(up_pub_place, 'PALMERSTON NORTH') > 0 or
       index(up_pub_place, 'ROTORUA') > 0 or
       index(up_pub_place, 'WELLINGTON') > 0 or
       index(up_pub_place, 'WELLSFORD') > 0 or
       index(up_pub_place, 'WHITIANGA') > 0 or
       index(up_pub_place, 'LOWER HUTT') > 0 or
       index(up_pub_place, 'NORTH SHORE') > 0 or
       index(up_pub_place, 'PETONE') > 0 or
       index(up_pub_place, 'GREENLANE') > 0 or
       index(up_pub_place, 'TĀMAKI MAKAURAU') > 0 or
       index(up_pub_place, 'TAMAKI MAKAURAU') > 0 then do;

        Pub_country = "New Zealand";

        if index(up_pub_place, 'AUCKLAND') > 0 then Pub_city = "Auckland";
        else if index(up_pub_place, 'NORTH SHORE') > 0 then Pub_city = "Auckland";
		else if index(up_pub_place, 'TĀMAKI MAKAURAU') > 0 then Pub_city = "Auckland";
		else if index(up_pub_place, 'TAMAKI MAKAURAU') > 0 then Pub_city = "Auckland";
		else if index(up_pub_place, 'LOWER HUTT') > 0 then Pub_city = "Wellington";
		else if index(up_pub_place, 'PETONE') > 0 then Pub_city = "Wellington";
		else if index(up_pub_place, 'GREENLANE') > 0 then Pub_city = "Auckland";
        else if index(up_pub_place, 'BLENHEIM') > 0 then Pub_city = "Blenheim";
        else if index(up_pub_place, 'CAMBRIDGE') > 0 then Pub_city = "Cambridge (NZ)";
        else if index(up_pub_place, 'CHRISTCHURCH') > 0 then Pub_city = "Christchurch";
        else if index(up_pub_place, 'DUNEDIN') > 0 then Pub_city = "Dunedin";
        else if index(up_pub_place, 'HAMILTON') > 0 then Pub_city = "Hamilton";
        else if index(up_pub_place, 'LINCOLN') > 0 then Pub_city = "Lincoln (NZ)";
        else if index(up_pub_place, 'MASTERTON') > 0 then Pub_city = "Masterton";
        else if index(up_pub_place, 'NELSON') > 0 then Pub_city = "Nelson";
        else if index(up_pub_place, 'OTAKI') > 0 then Pub_city = "Otaki";
        else if index(up_pub_place, 'PALMERSTON NORTH') > 0 then Pub_city = "Palmerston North";
        else if index(up_pub_place, 'ROTORUA') > 0 then Pub_city = "Rotorua";
        else if index(up_pub_place, 'WELLINGTON') > 0 then Pub_city = "Wellington";
        else if index(up_pub_place, 'WELLSFORD') > 0 then Pub_city = "Wellsford";
        else if index(up_pub_place, 'WHITIANGA') > 0 then Pub_city = "Whitianga";
        else Pub_city = "Unknown";

    end;
    else do;
        Pub_country = "";
        Pub_city = "";
    end;

    drop up_pub_place;
run;
%mend;


/* Check for NZ publisher and NZ uni press */
%macro NZ_pub_step2(input, output);
data &output;

    set &input;

	   length NZ_place $32.;
	/* determine publication place */
	if Pub_country = 'New Zealand' then
	do;
		NZ_place_publication = 1;
		if Pub_city='Unknown' then NZ_place="NZ/Aotearoa";
			else NZ_place = Pub_city;
	end;
	
	/* determine publisher origin */
	array kw1[17] $33 _temporary_ 
	("Aotearoa", "NewZealand", "New Zealand", "N.Z", "N.Z.",
	"Auckland", "Hamilton", "Palmerston", "Wellington",
	"Otago", "Canterbury", "Victoria University", "Massey", "Waikato", "Lincoln University",/* Added NZ univeristy press names*/
	"Nelson", "Christchurch", "Dunedin",
	"Māori", "Maori", "Wānanga", "Wananga", "NZCER");
	
	do i=1 to countw(Pub_publisher, ";");
		word=scan(Pub_publisher, i, ";");
		do j=1 to dim(kw1);
			/* doc says if we don't use trim(), trailing and leading spaces are considered as
			part of the string being searched? but using it does make this code work much better now */
			if index(word, trim(kw1[j])) then NZ_publisher=1;
		end;
	end;
	drop i j;
	
	/* determine if publisher is (NZ?) university press */
	array kw2[2] $33 _temporary_ 
	("University", "university");
	
	do i=1 to countw(Pub_publisher, ";");
		word=scan(Pub_publisher, i, ";");
		do j=1 to dim(kw2);
			if index(word, trim(kw2[j])) then is_uni_publisher=1;
		end;
	end;
	drop i j;
	
	array kw3[2] $33 _temporary_ 
	("Press", "press");
	
	do i=1 to countw(Pub_publisher, ";");
		word=scan(Pub_publisher, i, ";");
		do j=1 to dim(kw3);
			if index(word, trim(kw3[j])) then is_press= 1;
		end;
	end;
	drop i j;
	
	array kw4[8] $33 _temporary_ 
	("Auckland", "Waikato", "Massey", "Victoria", "Wellington",
	"Canterbury", "Lincoln", "Otago");
	
	do i=1 to countw(Pub_publisher, ";");
		word=scan(Pub_publisher, i, ";");
		do j=1 to dim(kw4);
			if index(word, trim(kw4[j])) then is_NZ_uni= 1;
		end;
	end;
	drop i j;
	
	if NZ_publisher=1 and is_NZ_uni=1 and is_uni_publisher=1 and is_press=1
		then UNI_press=1;
		
	drop is_NZ_uni is_uni_publisher is_press word;
	
	run;

%mend;
