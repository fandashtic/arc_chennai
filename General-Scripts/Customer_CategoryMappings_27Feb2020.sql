Truncate Table Customer_CategoryGroups
GO
Truncate Table Customer_Groups
GO
Truncate Table Customer_Mappings
GO
Insert Into Customer_CategoryGroups(CategoryGroupName) Select 'GR4'
Insert Into Customer_CategoryGroups(CategoryGroupName) Select 'GT'
Insert Into Customer_CategoryGroups(CategoryGroupName) Select 'ISS'
Insert Into Customer_CategoryGroups(CategoryGroupName) Select 'ITC'
Insert Into Customer_CategoryGroups(CategoryGroupName) Select 'SWD'
GO
Insert Into Customer_Groups(GroupName) Select 'Bakery'
Insert Into Customer_Groups(GroupName) Select 'Canteen'
Insert Into Customer_Groups(GroupName) Select 'Chemist'
Insert Into Customer_Groups(GroupName) Select 'Consumption Centres'
Insert Into Customer_Groups(GroupName) Select 'Convenience'
Insert Into Customer_Groups(GroupName) Select 'Convenience CDM'
Insert Into Customer_Groups(GroupName) Select 'Convenience Non CDM'
Insert Into Customer_Groups(GroupName) Select 'Fancy Stores'
Insert Into Customer_Groups(GroupName) Select 'FC Enrolled'
Insert Into Customer_Groups(GroupName) Select 'FC Target'
Insert Into Customer_Groups(GroupName) Select 'Grocery'
Insert Into Customer_Groups(GroupName) Select 'Hawker'
Insert Into Customer_Groups(GroupName) Select 'Independent Self Service Stores'
Insert Into Customer_Groups(GroupName) Select 'Institution'
Insert Into Customer_Groups(GroupName) Select 'PG&C'
Insert Into Customer_Groups(GroupName) Select 'Retail'
Insert Into Customer_Groups(GroupName) Select 'Retail Convenience'
Insert Into Customer_Groups(GroupName) Select 'SCP'
Insert Into Customer_Groups(GroupName) Select 'Service'
Insert Into Customer_Groups(GroupName) Select 'Town Wholesale'
Insert Into Customer_Groups(GroupName) Select 'Wholesale'
GO
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select '%ARC-CIG-422','JESUS TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select '%ARC-CIG-456','YUVA STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ACGR2194','VIJAYALAKSHMI NAATU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC001','ABCD',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC002','P.K.DURAISAMY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC003','COUNTER SALESMAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC004','C.S. SIDDARTH',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC01','C.S.VIGNESHWAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK1','SRI KRISHA BAKERY & SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK10','MAYURA BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK100','VENKADESWARA SWEETS (PLM) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK101','COLLEGE BAKERY(CPLM) -A',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK102','AJANTHA BAKERY & SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK103','NEW UMA SWEETS & BAKERY -PLM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK104','BALARAM SWEETS(PLM) -C',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK105','JAYA BAKERY(PLM) -A',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK106','OM MURUGA HOT CHIPS(PLM) -C',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK107','COLLEGE BAKERY(PLM) -A',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK108','JINNY FOODS -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK109','ELSHADAI HOT CHIPS- Z-PLM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK11','S.L.B CAKE & SWEET BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK110','SRI RAGAVENDRA BAKERY-PAL',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK111','AALAYAM HOT CHIPS(PML) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK112','ADYAR BAKERY(PLM) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK113','SRI THIRUMALA IYENGAR BAKERY & SWEETS(PML)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK114','NELLAI JAYARAM SWEETS -C',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK115','SARAVANA SWEETS&BAKERY (PML) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK116','CHENNAI NEW HOT PUFFS(PML) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK117','THANGARATHINAM SWEETS (PML) -A',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK118','VENKATESWARA SRI SWEETS & BAKERY (PML) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK119','R.C.AGARWAL SWEETS(PLM) -C',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK12','KESAVAN HOT CHIPS & SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK120','SRI GANAPATHI SWEETS & BAKERY-POZ',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK121','VINAYAGA SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK122','AMMAN SRI BAKERY(POZ) -A',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK123','AYYA SWEETS&BAKERY STALL(POL) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK124','SRI VINAYAGA SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK125','SRI VENKATESWARA SWEETS & BAKERY-POZ',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK126','ELLIOT FOODS (SELYUR)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK127','S.L.J.IYYANGAR BAKERY { MDM }',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK128','CHENNAI HOT CHIPS (SLR)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK129','BALAN SWEETS ( KRM )',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK13','NEW MARUTHI BAKERY(AKP) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK130','NEW SARAVANA BAKKERY & SWEETS (HPM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK131','NALA SWEETS & BAKERY(AGRM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK132','NEW ROYAL SWEETS & BAKERY(HPM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK133','SRI LAKSHMI BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK134','NEW LAKSHMI BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK135','SRI LAKSHMI BAKERY & SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK136','ARCHANA BAKERY (TIRUNEERMALAI)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK137','SRI LAKSHMI SWEETS & BAKERY - THMU',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK138','SRI MAHAVEER SWEET & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK139','SRI KRISHNA SWEET & BAKERY- 9840397056',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK14','SRI AMMAN SWEETS & BAKERY (AKP) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK140','SRI AARTHI SWEETS - 8122993312',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK141','SREE VENKATESHWARA SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK142','SRI KRISHAN SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK143','TULASI SWEETS-9840665186',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK144','BALAJI BAKERY-9840249035',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK145','RAGAVENDRA BAKERY (OPVM) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK146','SRI GANAPATHI SWEETS & BAKERY_MDM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK147','SRI THIRUMAL IYENGAR BAKERY & SWEETS_CHRM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK15','MERIN HOT PUFFS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK150E&DADJ','SLB CAKE HOUSE',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK151','SRI VENKADESWARA BAKERY_MADAMPAKKAM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK151E&DADJ','LAKSHMI BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK152E&DADJ','SRI VENKATESHWARA SWEETS - ALR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK153E&DADJ','P.G.V. DEVAR COOL BAR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK154E&DADJ','SELVAM SWEETS -PLTL',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK155E&DADJ','SRI BALAKRISHNAN SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK156E&DADJ','SHANTHI SWEETS -NGN',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK157E&DADJ','VIGNESH COOL BAR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK158E&DADJ','BREAD TALK-',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK159E&DADJ','Sri lakmi store',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK16','SREE DURGA SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK160E&DADJ','Zam zam cool bar',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK161E&DADJ','venkateshwara cool bar',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK162E&DADJ','JAYALAKSHMI SWEETS- GOW',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK163E&DADJ','LAKSHMI BAKERY -GOW',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK164E&DADJ','Sri lakshmi cool drinks',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK165E&DADJ','KJR sweets',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK166E&DADJ','Balaji bakery-NGN',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK167E&DADJ','Sneha bakery-NGN',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK168E&DADJ','Rajeshwari bakery',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK17','TK PT COOL BAR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK18','MAHALAKSHMI IYYANGAR BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK19','MUTHU KUMARAN SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK2','SREE AARTHY SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK20','SHANTHI SWEETS(CHE)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK21','SNEHA BAKERY.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK22','DEEPAM FOODS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK22E&DADJ','NEW LAND BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK23','RAGAVENTHAR SRI IYANGAR BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK23E&DADJ','VEL MURUGA BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK24','SRI KRISHNA HOT CHIPS.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK25','ANNAI BISCUITS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK26','KANCHI BAKERY.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK27','CHITRA SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK28','SELVAM SWEETS BALARAM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK29','BAKERY GARDEN',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK3','ABIRAMI SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK30','SELVAM SWEETS .',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK301','LAKSHMI IYYANGAR BAKERY GOW',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK31','ROYAL BAKERY-',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK32','BALA SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK33','SRI VENKATESWARA BAKERY.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK34','MARUTHI BANGALORE  BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK35','GURU GANESH SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK36','ANAND COOLBAR.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK37','NEW SENTHIL SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK38','BALAKRISHNA SWEETS.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK39','SRI AARTHI SWEETS.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK4','SRI VIGNESHWARA SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK40','DELICIOUS BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK41','AMIRTHAM BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK42','ANANDHI BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK43','SELVAM SWEETS.',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK44','SRI BALAJI BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK45','JINNY FOODS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK46','KUMARAN MEDICAL-CHR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK47','V.P.S BARKERY -CHR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK48','HOT PUFFS & CHIPS SWEETS & SAVOURIES',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK49','LAND NEW BAKERY (CHR) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK5','ADYAR BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK50','SRI SAI BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK51','GURU BAKERS-CHR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK52','SRI SAI ICE CREAM & SNACKS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK53','SRI SATHYA SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK54','NEW SARAVANA BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK54E&DADJ','SV SWEET BACKER',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK55','PERUMAL BAKERY CHR - A',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK56','SRI ASTALAKSHMI SWEETS&BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK57','JP SWEETS(ETBM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK58','GRANDSWEETS & BAKERY NEW(ETBM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK59','HARIS HOT CHIPS(NEAR SABARI TEASTALL)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK5E&DADJ','NANDHINI SWEET',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK6','KUMARAN BAKERY (AGARAM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK60','ELLIOT FOODS - (GOW)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK61','ANJALI SWEETS-BAKERY-044-22443642',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK62','SRI KRISHNA SWEETS & BAKERY 2- 9840397056',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK63','RANGA SWEETS(HPM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK64','JANANI SWEET (HPM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK65','MAHALAKSHMI AYYANGAR BAKERY (HPM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK66','SRI GANAPATHY SWEETS & BAKERY (KRM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK67','SRI RAMALAKSHIMI SWEET & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK68','LAKSHIMI HOT PUFFS (MDM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK69','LAKSHMI SWEETS - MDM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK7','LAKSHMI HOT PUFFS 4  (AGRAM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK70','A.K.CORNER (MDM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK71','LAKSHMI HOT PUFFS (AGRM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK72','JAYALAKSHMI SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK73','HARSHINI SWEETS & BEKRY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK74','COFFEE SPOT',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK75','KUTTY COOL BAR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK76','USHA BAKERY - 9043269534',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK76E&DADJ','NEW MORDERN BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK77','R.K HOT PUFFS & CAKES',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK78','ARCHANA BAKERY(TMR) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK79','ANJALI SWEETS(NGK) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK8','LAKSHMI HOT PUFFS 3 (AGARAM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK80','SOLAI SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK81','ELAKKIYA SWEETS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK82','LAKSHMI SWEET STALL(O.PLM) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK83','STAR NEW BAKERY (O.PLM) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK84','VENKADESWARA SWEET & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK85','LAKSHMI SWEET & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK86','VENKADESWARA SWEETS - OPP MUGIL',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK87','THAMARAI HOT CHIPS-OPLM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK88','GANESH SWEETS & BAKERY(OPLM) -B',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK89','SRI LAKSHMI SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK9','MERIN&MERISHA CHOCLATEHOUSE(AGRM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK90','K.J.R SWEETS-AGRM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK91','SRI PATHMAVATHI SWEETS-AGRM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK92','LAKSHMI STORE -AGRM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK93','SRI VENKATESHWARA SWEETS & BAKERY-AGRM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK94','SHARON BAKERY(PAL) -A',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK95','R.K SWEET & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK96','ANBU SWEETS & BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK97','BAKERY GARDEN 2',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK98','UTHAYAM HOT CHIPS & BOLI STALL',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCBAK99','KRISHNA SRI BAKERY(PLM) -C',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-01','SRI KARPAGA VINAYAGAR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-02','MAHALAKSHMI SHOPE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-03','SRI MURALI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-04','KUMARAN MEDICALS-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-05','TAAJ MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-06','SAKTHI FANCY STORE-POZ',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-07','MURUGAN MEDICALS-POZ',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-08','M.R. MEDICALS -PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-09','S.A.FASHION JEWELLERY-NGK',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-10','P.S.SEEVAL STORES NAATU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-11','GOOD HEALTH PHARMACY-NGN',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-20','SRI MARAN PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-21','MAHALAKSHMI POOJA STORE-POZ',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE-22','S.B. FANCY STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE23','JANISH MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE24','PACHAIYAPPA PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE25','VAISHNAVI PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCHE26','ANNAMANI FANCY STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-002','AADHI LINGAM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-003','ALTAF',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-005','ANZARI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-006','ARANGANTHAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-007','ARUMUGAM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-008','B. SATHISH KUMAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-009','BALAJI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-010','C MURUGAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-011','CHANDRASEKAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-012','D.S. SIVABALAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-013','DHASTHAGRI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-014','DAMODHARAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-015','G. KARUNANITHI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-016','G.R.BABU',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-017','GANESH BABU',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-018','HUBERT',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-019','JAYAKUMAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-020','KUMAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-021','LOYALA',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-022','MADASAMY',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-023','MOHAMED ALI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-024','MURUGALINGAM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-025','MURUGAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-027','MUTHU',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-028','PERUMAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-029','RAJ KUMAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-030','RAJAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-031','RANGANATHAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-032','RANJITH',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-033','RAVI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-034','S SEKAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-035','S.DURAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-036','SASIKUMAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-037','SELVADURAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-038','SELVAM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-039','SENTHIL RAJ',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-040','SHANTHI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-041','KUMAR TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-042','SARAVANA STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-043','ABDUL HAMEED(NGL)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-044','CAMP SNACKS(CMP)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-045','SARAVANA STORE(CPM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-046','CAPTAIN CORNER',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-047','D.KUMARAVEL(POL)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-048','BHAVANISEKAR(NALUR)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-049','C.MURUGAN(PLRM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-050','SIVA TEA STALL(PLM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-051','MUTHU TEA STALL(PLM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-052','S.GOVINDARAJ(PLM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-053','GOKULAM TEA STALL(PLM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-054','G.SELVADURAI(HPM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-055','SHANKAR STORE(HPM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-056','ANGEL TEA STALL(TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-057','M.M.PROVISION(TBM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-058','R PONVEL CHETTIAR SONS_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-059','KANI STORE(TBM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-060','SRI ANANDHA STORE - SLR_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-061','DHARSHINI TRADERS-CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-062','ZAKARIYA STORES(W.TBM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-063','J.P.RAJA STORE(SLR)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-064','LINGAM STORE (SLR) V_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-065','JEEVA STORE(E.TBM) (V)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-066','BLESSING STORE(W.TBM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-067','KAVITHA STORE ( CG-KPM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-068','GANESH NEW STORE(CG)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-069','ABDULA STORE(WTBM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-070','ANANDA STORE(TBM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-071','DURAIAPPASTORE(TBM)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-072','SINGH STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-073','R.P.K.STORES_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-074','A.M.NAZEER (PLM) (ITD)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-075','ANNAI STORE (PLM (V) -B_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-076','AYYAN STORES(PML) -A_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-077','FAROOK BASHA STORE (PML) (V) -A_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-078','KARPAGAM SRI STORE(PLM) -B_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-079','KURUTHU STORE(CHR) (ITD)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-080','N.B STORE (CHR)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-081','P.T KOTHANDAM & SONS(PLM) (V) -C_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-082','PRAKASH SWEETS M(PLM) (ITD)_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-083','PRIYA STORES(PLM) (V) -A_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-084','ROJA SRI STORES(O.PLM) -A_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-085','SRI KAMATCHI AMMAN ST-AKP-ITD_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-086','P.VIJAYALAKSHMI STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-087','SARAVANA STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-088','SRI KAMATCHI STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-089','MURUGAN SRI TRADERS_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-090','RAJENDRA STORE',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-091','KAMARAJ STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-092','PON PANDIAN STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-093','SMK STORE-CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-094','MURUGAN STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-095','PRAKASH STORES_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-096','AYYAPPAN STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-097','R K STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-098','GANESH STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-099','SRI VENKATESHWARA STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-100','ARPUTHAM STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-101','V K MAILAGAI_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-102','SRI GANESH STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-103','M.P NADAR & SONS_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-104','KRISHNA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-105','MAGESHWAR STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-106','NEW VINAYAGA STORE.._CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-107','AMBICA STORE.WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-108','SRI MUTHUMALI AMMAN_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-109','ANANDHA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-110','ANDROO STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-111','TA NADAR STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-112','THILAGAM STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-113','SHANMUGA STORE _WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-114','SRI DURAIAPPA AGENCY WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-115','MAHALAKSHMI STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-116','INDIRA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-117','JAYA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-118','POOMANI STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-119','SOUNDARAPANDIYAN STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-120','SRI AYYANAR STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-121','SRI MUTHARAMMAN STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-122','THARANI STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-123','TS RAJAMANI STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-124','JASMINA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-125','CHELLAM STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-126','MALRAJA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-127','SARAVANA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-128','SELVASEELAN STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-129','OM SAKTHI STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-130','MUTHARAMMAN.MEDA_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-131','JAYA PROVISION_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-132','MURUGAN STORE _WHOL_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-133','KANAGAMANI STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-134','ANBUMANISTORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-135','MAJ BASHA STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-136','SELVARANI STORE_WH_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-137','SM  TRADERS',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-138','SRI PERIYANDAVAR_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-139','BABU STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-140','NB STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-141','AYYAN STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-142','SRI ARCHANA STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-145','BAVATCHI TEA STALL(SAN)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-146','AYODHIYA STORE(SAN)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-147','CHANDRA TEA STALL(W.TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-148','ELITE CAFE(MPDU)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-149','CITY PLACE(MPED)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-150','FORUM TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-151','GANAPATHI STORE(W.TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-152','BASHA STORE(ALDUR)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-153','RPK STORES(TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-154','LAKSHIMI STORE (NA)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-155','SAKTHIKANI STORES(W.TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-156','THANGAM STORE(CHRM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-157','THANGAM STORE(W.TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-158','SENTHL STORE(W.TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-159','NEW GANESH STORE(ARGRM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-160','MURUGAN STORE(NGL)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-161','SIDDIK STORE(W.TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-162','SHAGUL ANSARI(W.TBM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-163','DIWANMOHIDEEN',1,12
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-164','KAJA BUNK(ALDUR)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-165','PRABHA TEA STALL',1,12
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-166','INDIAN COFFE(HPM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-167','CARNIVAL TEA STALL(MDM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-168','IYYAPA TEA STALL(HPM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-169','D & EAT SNACKS(HPM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-170','%VIVASAAYAM STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-171','BHAGAVATHI TEA STALL(PLRM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-172','SAKTHI TELECOM(CPM)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-173','PRIYA COOL BAR-NALUR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-174','LINGAM STORE-RAJ',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-175','CITY SNACKS',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-176','LINGAM DURAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-177','PARVATHI STORE - NAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-178','LENIN NEWS MART',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-179','DHARSHINI TEA STALL - ADAM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-180','LENIN TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-181','DHANASEKAR-HW',1,12
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-182','INDIAN TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-183','C.G.COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-184','GST TEA STALL',1,12
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-185','GANI STORE.-HW',1,12
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-186','SAKTHI KANI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-187','AGNI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-188','BALAJI BUNK-CMP',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-189','DANIEL SNACKS-E-TBM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-190','PAVITHRA STORE -CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-191','P.J STORE -CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-192','S.K TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-193','JANAKI STORE-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-194','SEKAR STORE-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-195','SHANTHI TEA STALL-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-196','SURYA TEA STALL-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-197','RAMYA TEA STALL-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-198','STEPHEN STORE-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-199','MANI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-200','DURAI STORE-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-2000','JAI PRAVEEN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-2001','S.M.K.STORE_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-2003','GANAPATHY R_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-2004','UNIK ASSOCIATES (NILGGIRIS)_CIG',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-201','RAGHUL SNACKS-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-202','VELMURUGAN TEA STALL-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-203','THAMEEM COOL BAR-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-2031','ANANDH_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-204','ISMAIL STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-205','KANAGARAJ COOL BAR-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-206','RAJESH COOL BAR-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-207','SAI MAGESHWARI AGENCIES',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-208','SAI DEEPAN STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-209','GOLDEN TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-210','LAKSHMI STORE-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-211','%PARVATHI STORE - NANGANALLUR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-212','%ANS COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-213','MATHINA COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-214','SIVA STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-215','THILAGAM STORE - ALANDUR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-216','DURAI BUNK',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-217','RIZWAN HW',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-218','JEYAM STORE-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-219','APN TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-220','NIVETHA COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-221','UDAYA SURYA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-222','CHENNAI CAFE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-224','NATHAN TEA STALL',1,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-225','ARUSH STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-226','AYYANAR SUPER MARKET_WH-CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-227','AYYA THANGAM STORE_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-228','SUBRAMANI NEWS MART-CIG1',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-229','MURALI STORE-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-235','M. R. TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-236','SAI NEWS MART',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-237','LENIN NEWS MART-2',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-238','RAJA STORE_ULL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-239','BHAVANI STORE ULL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-240','KARTHICK COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-241','KUTTY TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-243','VIJI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-244','VJ TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-245','RAHIM COOL NAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-246','SELVAM STORE_ULL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-247','SK TEA STALL_ULL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-248','ANBU STORE_ULL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-249','RAMAR TEA STALL_NAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-250','BHAGAVATHI TEA STALL(SAN)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-251','MADHAVAN COOL BAR_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-252','BALAMURUGAN COOL BAR_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-253','JAGAN TEA STALL_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-254','KAMAL TEA STALL_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-255','PANNER COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-256','MATHI TEE STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-257','M.PRAKASH SWEETS -CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-258','DURAI-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-259','GOVARTHANAN HW',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-260','ANNAI STORE-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-261','BALA VIGNESH-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-262','KRISHNA TEA STALL_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-263','SHANTHI TEA STALL1-CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-264','ANDAVAR TEA STALL1_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-265','SELVARANI_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-266','SAKTHI LINGAM_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-267','NGK STORE_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-268','DIVYASTORE_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-269','PRIYA STORE_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-270','DIVI STORE_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-271','JENITA STORE_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-272','JANAKI STORE_TBM_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-273','SENKOTTAIYAN SUPER STORE_TBM_CG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-274','AYYAPPA TEA STALL_NAN_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-275','MOUNT CAFE_ULL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-276','SENTHUR MURUGAN STORE_NAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-277','PERUMAL BUNK',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-278','ANAND TEA STALL_NAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-280','PANDIAN STORE_NGL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-281','JUICE LAND_NGL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-283','MATHINA STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-284','ALFA TEA STALL1_NGL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-285','G. P. STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-286','SAMY TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-287','GOKULAM SNACKS_NGL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-288','DURAIAPPA SUPER STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-289','ANDRO MALIGAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-291','SHANTHI NEWS MART',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-292','JUICE MASTER',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-300','GANI HW',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3001','RAGAVENDRA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3002','JETTAR COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3003','PAVITHRA COOL BAR_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3004','SURESH TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3005','INDHU COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3006','S.M.K.KRISHNA STORE_CG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3007','GAPATHY.R_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3008','A ONE PROVISION STORES_CIG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-301','HORIZON ENTERPRISES(URPKM)',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3011','DHARUN',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3012','AMIRTHARAJ',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3013','SRI SHANTHI SWEETS & BAKERY(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3014','JAI PRAVEEN_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3015','GANAPATHY_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3016','GOWTHAM_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3017','AJITH KUMAR_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3018','SMK STORECG',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3019','KARTHICK.S_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-302','AMP ANNAI STORE(PLM)',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3020','BOOMINATHAN TEA STALL_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3021','ASHWIN COOL BAR_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3022','NAVEEN.N_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3023','FRIENDZ SSUPER MARKET(CPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3024','DURAIAPPASTORE(TBM)_NGST_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3025','SHAGUL HAMEED_CIGHW',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3026','MJ COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3027','GOKULAM STALL(PLM-CIG)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3028','MANIKANDAN ITC',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-303','GANI_HAWKER',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3030','SWASTIK AGENCIES_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3031','MURUGAN STORE(T.NAGAR)_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3032','VARUN ENTERPRISES SHELL-CIG',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3033','A.M LAKSHMI STORE_CIG',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3034','SWARNAM TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3035','DHANALAKSHMI BUNK',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3036','SRI RAJESHWARI STORES SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3037','ZAM ZAM TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3040','CHANDRASEKAR TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3041','TRIAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3042','SHIVA STALL-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3043','KARTHICK_NTD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3044','NAVEEN.N_NTD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3045','ANAND_NTD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3046','GOWTHAM_NTD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3047','AJITH KUMAR_NTD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3048','JAI PRAVEEN_NTD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3049','SAI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3050','SPM CANTEEN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3051','MURUGAN STORE2(NGL)',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3052','ABDUL HAMMED',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3053','VASANTH_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3054','VASANTH_NTD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3055','TOP ZONE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3056','JTS COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3057','MELODY TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3058','SK TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3059','KANNAN TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3060','METRO TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3061','SUBRAMANI NEWS MART',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3062','MOORTHY TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3063','GAYATHRI NEWS MART',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3064','VINAYAGA COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3065','BISMILLA STORE-CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3066','ANSARI STORE-CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3067','IYYAPPA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3068','ANNAI ANGADI-CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3069','AKSHAYA STORE_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3070','ANANDSTORE_CIG',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3071','VASANTHA TEA STALL_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3072','RAGHU_DSPM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3073','ANNADURAI-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-3074','ANNA TEA STALL_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-32','ZAHARIYA SUPER STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-330','KARTHIC T.S',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-331','VASANTHA TEA STALL-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-332','AMMA RESTORENT-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-333','E.CAFE-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-334','METRO JUSE T.S',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-335','SHAGUL NG TBM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-336','AARTHIKA TEA STALL-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-337','MURUGAN MALLIGAI-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-338','SHAGUL TEA STALL-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-339','ZATTAR SNAKES-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-340','GANESHAN MALLIGAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-341','SM COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-342','TASTY POINT-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-343','SOUNDHARYA T.S',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-344','RANGAM TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-345','CITY CAFE STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-346','RANJITHA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-347','MUTHU TEA STALL-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-348','BABY TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-349','PONNU TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-35','ZAHARIYA MALIGAI STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-350','RAMU TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-351','RAGHUMAN TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-352','HARI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-353','MANI STORE-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-36','R.P.K MALIGAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-360','RUTH STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-361','JANU COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-37','R.P.K SONS',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-38','R.P.K SUPER STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-389','KARTHICK STORE_CIG',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-39','ROJA SRI MALIGAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-390','GOWTHAM STORE_CIG',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-391','NAVEEN STORE_CIG',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-392','KESAVA PRASATH_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-393','ANNA COOL BAR_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-394','SENTHIL COOLBAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-395','RAJ TEA STALL_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-396','VANI STORE_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-397','BANU STORE_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-398','THAMAN STORE_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-399','BHUVANI STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-40','ROJA SRI MARKET',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-401','A ONE PROVISION STORES-ALR',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-402','CHANDRU TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-403','UDAYA STORE TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-404','ANAND STORE_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-405','JOSHNA STORE_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-406','BABU TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-407','SANKAR STALL_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-408','DANIEL TEA STALL_CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-409','SATHISH TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-41','ROJA SRI SUPER STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-410','GOWRI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-411','RANGA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-412','SILON TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-414','MARRY TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-415','DHANA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-416','SING STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-417','SINDHANA STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-418','SERAN STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-42','DURAIAPPA MALIGAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-420','MURUGAN TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-421','ALLA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-422','DENA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-423','ANNA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-424','FUN STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-43','ANBU STORE -CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-44','ANSAR TELECOM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-45','A.D.TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-450','KUMAR STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-451','MALA SUPER STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-452','JOSH SUPER STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-453','JENI STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-454','PADMA STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-455','BHARANI STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-456','NACHI SUPER STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-457','DEVI SUPER STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-458','PREM STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-459','PRAVEEN STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-46','SELVI T.S-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-460','SANGEE STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-461','MURUGAN STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-462','JESUS SUPER STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-463','MADHA STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-464','BHUVAN STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-465','BABA STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-466','ALLA STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-467','ANDRU SUPER STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-47','JACK STORE CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-470','GANAPATHY STORE_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-48','JAIN STORE-CIG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-483','SELVASING STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-491','DHAMO TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-492','RAVI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-493','SELVAM_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-494','KUMAR_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-495','SHALLU STORE_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-496','MALLU STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-497','KARTHICK STORE_CIGM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-498','GANAPATHY TEA STALL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-499','ARUMUGAM COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-500','KUMAR STORE_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-501','PERUMAL COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-502','PERUMAL TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-503','AJITH K_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-950','BHAVANA STORE_CG',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-951','SELVAM STORE_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-CIG-952','PRASAD STORE_CIGSM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM1','MOHAN NATTUMARUNTHU KADAI',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM10','GANESH MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM100','GOKULAM MEDICALS ( CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM101','GEETHA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM102','AMBAL SRI MEDICAL (CHR) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM103','MANI PHARMACY(E.TAM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM104','SHRI SAIRAM MEDICAL (E.TBM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM105','MANIKANDAN SRI MEDICAL(HPM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM106','SURIYA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM107','KRISHNA SRI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM108','SRI MEENAKSHI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM109','GANESH MEDICALS MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM11','RANJANI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM110','S.M.R MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM111','MAHALAKSHMI MEDICAL-NGL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM112','SHRI VARSHINI PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM113','ROTARY CENTRAL MARGARET SIDNEY HOSPITAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM114','GET WELL PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM115','S.E.SOLOMON PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM116','VASAN MEDICAL-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM117','GOOD HEALTH PHARMACY-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM118','MEENA MEDICAL-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM119','SRI KUMARAN PHARMACY-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM12','DHAYA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM120','MURUGAN MEDICALS-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM121','MUTHU MEDICAL-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM122','SELVI MEDICAL-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM123','ANNAI MEDICALS-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM124','JRV MEDICAL-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM125','SRI RAM MEDICAL-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM126','SUBRAMANI STORE-OPLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM127','MEENA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM128','SRI KUMARAN PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM129','GOOD HEALTH PHARMACY (2)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM13','JAYAM MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM130','ROJA NATUMARUNTHU KADAI 2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM131','FATHIMA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM132','GOKULAM MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM133','HANIFA MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM134','MS MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM135','SRM MEDICALS-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM136','SRI KAMATCHI MEDICAL-PLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM137','SMR MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM138','BAWA MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM139','MEENATCHI MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM14','KANDASAMY MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM140','LAKSHMI MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM141','SS MEDICAL-PAVM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM142','SRA MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM143','SRI ABIRAMI MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM144','S.S MEDICAL-PAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM145','M/S J.R.V MEDICALS (PVM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM146','BAWA MEDICAL(PLM) -A',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM147','LAKSHMI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM148','S.S.MEDICALS(PLM) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM149','HEMA MEDICAL-PARI',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM15','MURUGAN MED & GEN STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM150','RAJALAKSHMI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM151','SRI VENKADESWARA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM152','VENKADESWARA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM153','KARTHIK MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM154','DIL MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM155','SRA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM156','VIJAYA DURGA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM157','VISSILA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM158','GURU PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM159','GANESH SRI MEDICALS (PML) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM16','PREETHI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM160','WORLD MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM161','KARTHICK MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM162','MUTHU MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM163','SELVI MEDICAL-PLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM164','R.R.MEDICALS-B',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM165','M.S.MEDICAL-PLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM166','SRI KAMATCHI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM1661','YUVAN MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM1662','PRASHNAVI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM167','SRI ABIRAMI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM168','S.R.A .MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM169','SHIFA MEDICALS(PLM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM17','PRIYA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM170','MURALI MEDICELS (PAL)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM171','MUDHUVAI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM172','JEYARAM MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM173','SRIDHAR MEDICALS-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM174','VAIDHIEASWARA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM175','GANESH MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM176','HARSHI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM177','CHENNAI MEDICAL(PML)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM178','GANESH SRI MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM179','MURUGAN MEDICAL(PML)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM18','KEERTHI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM180','SRI BALAJI MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM181','DAY 2 DAY MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM182','PONNI MEDICAL(PML)-N',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM183','SRI ABI MEDICAL(PML)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM184','DHANALAKSHMI MEDICAL(PML)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM185','SHIFA MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM186','SUSI FANCY-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM187','SUSI FANCY STORE-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM188','ANNAI MEDICAL(PML)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM189','RK MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM19','PONNI MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM190','RAGAVENDRA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM191','RR MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM192','M.R.MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM193','LAKSHMI BALAJI MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM194','MURUGAN MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM195','SRI GANESH MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM196','SRI BALAJI MEDICAL (PML)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM197','BALAJI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM198','PREMA MEDICALS -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM199','BALAJI MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM2','SRI DURGA NILAYAM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM20','MURUGAN MEDICAL & GENERAL ST',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM200','GOKULAM MEDICAL -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM201','DAY 2 DAY MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM202','S.K. MEDICAL(PML)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM203','RAGAVENDRA MEDICAL-POZ',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM204','ANNAI MEDICALS-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM205','MALMURUGAN MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM206','S.R.MMEDICALS (PLM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM207','MANIKANDAN MEDICALS-POL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM208','ASP MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM209','SRI THIRUMALA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM21','KANDASWAMY MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM210','MANIKANDA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM211','MANI KANDAN MEDICAL(POL) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM212','MANIKANDAN MEDICAL-POL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM213','MANIKANDAN MEDICAL(POL)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM214','ASP MEDICAL-POL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM215','MURUGAN MEDICAL & GEN STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM216','SRI THIRUMURUGAN MEDICALS-POZ',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM217','SRI THIRUMURUGAN MEDICAL-POZ',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM218','ASP MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM219','MURUGAN MEDICALS & GENERAL ST',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM22','PRIYA MEDIACL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM220','R.K.MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM221','MAHALAKSHMI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM222','SRI MURUGAN MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM223','KALAI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM224','SRI AMMAN MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM225','APARANA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM226','JAYA  MEDICAL (MDM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM227','RAM MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM228','VAEMBU MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM229','SREE SANJEEVI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM23','JAYAM MEDICAL-AKP',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM230','VALAN MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM231','SHAKTHI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM232','ANANTHI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM233','PADMA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM235','NEWGEN PHARMACY (AGRM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM236','SRI RAGAVENDRA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM237','JAYA MEDICAL(CPM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM238','SRI KRISHNA MEDICAL(CPM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM239','LALITHA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM24','DHANALAKSHMI MEDICAL-AKP',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM240','RAJAN STORE PROVISION& STATIONERY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM241','MSS PROVISION',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM243','ESWARI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM244','REMEDY MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM245','AMBIKA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM247','SUSHRADA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM248','K.S.RAJA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM249','ANU MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM25','PREETHI MEDICAL-AKP',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM250','RIGINEA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM251','FRIENDZ & CO MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM252','BARANI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM253','SRI BALAJI MEDICAL-TMKM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM254','SRI SILAMBU MEDICAL-TMKM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM255','SRI SILAMBU GENERAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM256','BUVANESWARI MEDICALS(TMR) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM257','SRI ABI MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM258','JANANI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM259','MALAR MEDICAL(PML) -A',2,18
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM26','DHAYA SREE MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM261','SRI BALAJI PHARMA AND SURGICAL(K.B)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM262','S.R.A NATTU MARUNTHU KADAI(PAL.M)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM263','SRINIVASAN NATTU MARUNTHU KADAI(PAL.M)\',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM264','TAN NATTU MARUNTHU KADAI(PAL.M)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM265','A.S.S NATTU MARUNTHU KADAI(PAL.M)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM266','BABU SEVAL STORE(PAL.M)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM267','SREE MANIKANDAN MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM268','GANESH MEDICALS-HPM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM269','SRI MAHA SATHUR KUNRU VINAYAGAR NATTU MARUNTHU-HPM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM27','NELLAI DEEN HERBAL STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM270','SRI KRISHNA MEDICALS-HPM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM271','SRI VENKATESWARA MEDICAL & GENERAL-HPM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM272','RAJA SEVAL STORE-PAMMAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM273','NILA NATTU MARUNTHU KADAI-PAMMAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM274','ANBU MEDICALS_PLVM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM275','SRI ANNAI MEDICALS_PAMMAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM276','NASEER MEDICALS_CHRM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM277','YOGOWA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM278','M.S.VIJAY PARMACY_SLR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM279','ARI MUTHU AYYA MEDICAL_VEL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM28','RAM SRI MEDICAL (CPM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM280','SRI MURUGAN MEDICALS_SLR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM281','SRI VENKATESWARA MEDICAL_E.TBM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM282','JAYA MEDICALS_E.TBM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM283','GANESH MEDICALS-MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM284','SRI SABARI MEDICALS_MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM285','NAVEEN MEDICALS_RAJAKILPAKKAM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM286','SRI KANI MEDICALS_MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM287','RIM MEDICAL CENTRE_MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM288','SRI MEENAKSHI MEDICALS_MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM289','MALAR MEDICALS_MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM29','MS MEDICAL-TIRUMUDI',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM290','AKC MARUNDHAGAM_MDM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM291','NAGA MEDICALS_RAJAKILPAKKAM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM292','MARIA PHARMACY_E.TBM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM293','BALA ABIRAMI MEDICALS_E.TBM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM294','VAEMBU MEDICAL_E.TBM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM295','CHITRA PHARMACY_E.TBM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM296','CHITHRA PARMACY_VEL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM297','RAM MEDICALS_E.TBM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM298','SRI SABARI MEDICALS_RAJAKILPAKKAM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM299','SRI PAKALAVAN MEDICALS_HPM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3','SIVASAKTHI SEEVAL STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM30','CHUKRA MEDICAL-THIRUMUDIVAKAM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM300','JAYARAM MEDICALS(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3001','SRI RANGA MEDICALS(CHM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3002','HEMA HARINI FANCY STORE(HPM)',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3003','NEW SRIRAM NATTU  MARUNTHU KADAI',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3004','BHUVANESHWARI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3005','GANESH FANCY STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3006','S.M.N.R NATTU MARUNTHU KADAI(HPM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3007','SRI KUMARAN MEDICALS(P.PLM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3010','NEW VASANTHAM FANCY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3011','VASANTHAM SINGAPORE SHOPPING',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3012','GOWTHAM NARAYANA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3013','RIGHT PHARMACY_POZ',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3014','BABA STORE_PML',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3015','M. S. K. MEDICALS & GENERAL STORE_CHRM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3016','SRI SHANMUGA MEDICAL_CHRM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3017','ARI SAI RAM MEDICALS_CHRM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3018','SRI GURU MEDICALS_CHRM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3019','SRI SAI RAM MEDICALS_CHRM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3020','ANNAI MEDICALS_CHRM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3021','SREE VENKATESWARA MEDICALS_CHRM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3022','ANJANEYA MEDICALS_AKP',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3023','THENNAGAM GENERAL STORE_CHRM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3024','NIRMAL MEDICALS_CHRM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3025','GOKULAM MEDICALS_PAMMAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3026','AGAS AGENCY (POOJA STORE)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3027','SHRI SAAI MEDICALS_PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM3028','KEERTHI MEDICALS- AKP',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM303','SURYA MEDICALS_HPM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM304','SHARMA MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM305','KARPAGAM STATIONARY_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM306','RAGAVENDRA MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM307','KUMARA LINGAM MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM308','SWATHI PHARMACY_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM309','SHRI KRISHNA MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM31','PARVATHI HOSPITAL-CHROMPET',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM310','RANOI MEDICAL & PHARMACY_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM311','SRI OM MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM312','ARI SAI PHARMACY_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM313','SURYAAS MEDICALS-TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM314','THIRUPATHI MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM315','DESHNA MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM316','P.G.R MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM317','MEDI HEALTH PHARMACY_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM318','LAKSHMI MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM319','SRI BRINDA MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM32','SRI BALAJI PHARMACY-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM320','ANNAI MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM321','K. S. MEDICALS-TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM322','JAYA MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM323','JAYAM MEDICALS_TBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM324','SRI JEYALAKSHMI MEDICALS_ADBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM325','CHINTHAMANI MEDICALS_ADBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM326','MOUNT MEDICALS_ADBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM327','K. P. MEDICALS_ADBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM328','THILAGA MEDICALS_ADBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM329','AL-AMEEN MEDICALS_ADBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM33','S.S MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM330','SHREE SRINIVASA MEDICALS_ADBM1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM331','JAYA MEDICALS_ADBM2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM332','PADMAVATHI PHARMACY_ADBM2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM333','SRI KUMURAN MEDICALS_ADBM2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM334','J. P. MEDICALS_ADBM2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM335','MEENAKSHI MEDICAL STORE_ADBM2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM336','ARVVI PHARMACY_ADBM2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM337','SRI SAKTHI MEDICALS_ADBM2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM338','JEYA MEDICALS_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM339','AROGYA PHARMACY_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM34','SRI AMBAL MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM340','SHINES MEDICALS_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM341','SRI GANESH PHARMACY_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM342','SRI BALAJI MEDICALS_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM343','JAYAM MEDICALS_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM344','SAI PHARMACY_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM345','ANANTHI MEDICALS GENERAL_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM346','G. V. MEDICAL & GENERAL_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM347','AMUTHA MEDICAL & GENERAL_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM348','ARASU MEDICALS_NAN1',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM349','VIMAL MEDICALS_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM35','SRI BABA MEDICAL(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM350','KATHIR MEDICAL_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM351','MEENAKSHI MEDICAL_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM352','SUNSHINE PHARMACY_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM353','MEENAKSHI MEDICALS_NGN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM354','SRI SUYAMBULINGAM MEDICINE_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM355','SAI MEDICALS_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM356','SRI VENKATESWARA MEDICALS_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM357','SRI SHANMUGA MEDICALS_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM358','SANTHOSH MEDICALS_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM359','MANI MEDICALS_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM36','KARUPAIH SRI MEDICALS-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM360','BABU MEDICALS_NAN2',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM37','KURUTHU MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM376','SRI SIVA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM377','PHARMAGEN MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM38','VEDHA PHARMACY-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM39','BALAJI PHARMACY-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM4','JAYANTHI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM40','DHEEN MEDICAL(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM401','A.S.P.MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM402','SRI RUTHRA DEVI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM403','SREE AYYAPPA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM404','SHAKTHI PHARMACY (SADHITHYA HOSPITAL)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM405','ARC FANCY STORE- POZ',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM406','POOJA FANCY STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM407','SRI SILAMBU MEDICALS & GENERALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM408','R.V.MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM409','S.S MEDICALS & GENERAL STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM41','JAYAM MEDICAL(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM42','LIMRAS MEDICAL(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM43','SRI GURU MEDICAL(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM44','KAVIYA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM45','NAVEEN MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM46','MARUTHI MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM47','SRI VIJAYA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM48','SURYA MEDICAL(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM49','VSP MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM5','S.PALSWAMY NATTUMARUNTHU KADAI',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM50','VEERA KAMATCHI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM51','SRI SAKTHI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM52','SHRI RAM MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM53','RAJ MEDICAL & GEN STORE',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM54','SRI ABIRAMI PHARMACY(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM55','BUVANESWARI MEDICALL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM56','GOKULAM MEDICALS-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM57','JASMIN MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM58','KASTHURI MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM59','OM VINAYAGA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM6','CHUKRA PHARMMACY(PLM) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM60','RAJALAKSHMI MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM61','SRI ABIRAMI MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM62','SRI MANI MEDICAL(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM63','SRI NEEVE IN LAKSHMI MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM64','SRI SRINIVASA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM65','TAJ MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM66','S.S.MEDICALS(CHR) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM67','SRI BABA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM68','SRI AMBAL MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM69','KURUTHU MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM7','S.M.P MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM70','ALAMU MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM71','INDIRA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM72','VADHA PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM73','SRI GURU MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM74','SRI VENKATESWARA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM75','JAYAM MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM76','DHEEN MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM77','LIMRAS MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM78','PRIYA MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM79','BALAJI PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM8','M.S.MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM80','SRI SRINIVASA MEDICAL { CHR } -SC',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM81','SAI RAM MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM82','SHANTHI MEDICALS (CHR) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM83','BS MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM84','DEEPA PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM85','RRASE MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM86','AGASH PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM87','PACHIYAPPA PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM88','JOTHIRAJAN MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM89','SRI SRINIVASA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM9','SHREE PADMAPRIYA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM90','SRI BALAJI PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM91','SARAVANA MEDICALS -CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM92','SHANTHI MEDICAL (CHRM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM93','NAVEEN MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM94','GURU MEDICAL-CHR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM95','KAVIYA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM96','RAJ MEDICAL& GEN STORE( CHR) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM97','SRI NEEVE IN LAKSHMI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM98','TAJ MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCM99','KASTHURI MEDICALS(CHR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV1','BALAKRISHNAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV10','SENTHIL _TL',1,6
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV100','DEVARAJ KUMAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV101','D.KUMARAVEL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV102','AZHAGARMALAIYAN COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV103','RAMALINGAM COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV104','ALAGU MUTHU.T',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV105','SELVA A.MUTHU',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV106','C.MURUGAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV107','SRI SAI GANESH STORE(MDM)',1,6
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV108','ANNA DURAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV109','R.BALAMURUGAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV11','SRINIVASAN_R2K',1,7
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV110','RAVICHANDRAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV111','SANTHOSH',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV112','SELVA MANI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV113','KUZHANDHI SIVA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV114','M.A TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV115','A.SELVAM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV116','GAYATHRI STORE(Z.PLM) -B',1,7
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV117','RENUKA STORE',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV118','SAI BALA STORE-AKP',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV119','BISMILLAH STORE-(PVM)',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV12','THARUN',1,7
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV120','AYYAPPA STORE (YUVARAJ)',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV121','JOTHI STORE-CHR',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV122','P.N STORE -CHR',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV123','THIRU SELVAM STORE-CHR',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV124','BALA MURUGAN STORES-NEM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV125','ANNAI MEDICAL-CHR',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV126','SRI ANNAPURANI STORE',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV127','LEE PROVISIONS & GENERAL STORE-CHR',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV128','VETRI COOL BAR -CHR',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV129','CHITRA STORE-CHR',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV130','ANNAI STORE-CHROMPET',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV131','ANNAPOORANI HOT PUFFS',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV132','SRI KRISHNA & SEKAR STORE-CHR',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV133','S.J.T STORE-NGK',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV134','PRIYA COOL BAR -OPLM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV135','AGMI COOL BAR-ZPLM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV136','SHRI SAROJINIDEVI RICE MANDI-PLM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV137','SAKTHI KOTHANDAN STORE-PAL',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV138','NOOR STORE -PLVM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV139','IRUTHIYA RAJA STORE',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV14','R.LOGANATHAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV140','JAYA ENTERPRISES-PAL',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV141','P.S.V FOOD CENTRE-PML',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV142','GANESH PROVISION(PML) -A',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV143','VISHWA STORE-PML',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV144','PAMMAL NIRMALA STORE',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV145','JAYAM PROVISION -PML',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV146','SRI VINAYAGA STORE -PML',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV147','SUNTEX MINI MART - PML',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV148','AMMAN STORES-PML',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV149','ABI AGENCY',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV15','MA COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV150','LAVANYA  BHARATHI-POL',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV151','B.NIRMALA PROVISION STORE -TMM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV152','RAMDEV PROVISIONAL STORE-TMM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV153','HARSHINI ENTERPRISES',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV154','MARINA BHAVAN-ZPLM',2,17
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV16','ANDAVAR TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV17','SEKAR TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV18','CHENNAI CHETTINADU COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV19','SRI SRINIVASA TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV2','RAMKUMAR BALAKRISH',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV20','VEDHA PHARMACY',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV21','P.LOYOLA',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV22','MADAN S.RAJ',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV23','SARAVANA KUMAR P.D',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV24','PAUL DURAI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV25','JAYA KUMAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV26','JEBARAJ',1,6
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV27','RAJESH SELVAM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV28','ABDUL HAMEED R.A',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV29','J.R.COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV3','V.RANGANATHAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV30','NEW CITY TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV31','AMUDHAM STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV32','PANDIAN COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV33','R.ALTAF',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV34','K.SENTHIL RAJ',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV35','SHANTHI COOL BAR-OPLM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV36','RAGAVENDRA COOL BAR-OPLM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV37','VENKATESWARA COOL BAR-OPLM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV38','KANAKARAJ COOL BAR-OPLM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV39','SELVAN STORE-OPLM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV4','ELAVARASI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV40','NEW NELLAI STORE-OPLM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV41','SUJATHA COOL BAR-OPLM',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV42','A.SARAVANAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV43','BUVANESH C.M',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV44','B.HUBERT',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV45','GANESAN SARAVANAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV46','VMS COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV47','AISHWARYA STORES',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV48','SADIQ COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV49','VASANTHA SNACKS-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV5','VIGNESH STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV50','SRIRAM TEA STALL-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV51','WELCOME TEA STALL-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV52','DURGA COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV53','GAYATHRI COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV54','JANA COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV55','PRIYA COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV56','CG SNACKS-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV57','PMA SNACKS-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV58','FAVOURITE CORNER-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV59','KARTHICK TEA STALL-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV6','SMR STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV60','RAMACHANDRAN BUNK-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV61','ASMEES SNACKS-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV62','GANAPATHI COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV63','SURESH COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV64','ARAFA TEA STALL-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV65','PAVITHRA COOL BAR-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV66','SHARMILA STORE-PAL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV67','S.DAMODHARAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV68','R.PRATHAP-TL',1,6
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV69','VENKATESH GOVIND',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV7','B.BALAJI',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV70','GOVINDRAJ',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV71','ALLWIN B.H',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV72','MOHEMAD ALLA',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV73','P.MURUGAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV74','PANDIAN BUNK-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV75','GOPIKA SNACKS-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV76','SUNDAR COOL BAR-PMLL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV77','CORNER TEA STALL-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV78','A1 JEEVA SNACKS-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV79','SRIGEE TEA STALL-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV8','RUDDRAHARI TRADERS WD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV80','SELVAM COOL BAR-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV81','MURUGAN COOL BAR-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV82','NARAYANAN TEA STALL-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV83','JILL JILL COOL BAR-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV84','SIVA TEA STALL-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV85','LK COOL BAR-PML',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV86','A.R.COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV87','CORNER SNACKS TIFFIN CENTER',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV88','MK COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV89','RAJALAKSHMI COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV9','DHILIP_TL',1,6
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV90','MALA STORE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV91','SRIGEE TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV92','VADIVUDAIAMMAN COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV93','RAMESH COFFEE',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV94','THANGAM COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV95','CHINAPPAN COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV96','KODAI TEA STALL',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV97','DHOWLATH COOL BAR',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV98','K.BALAKRISHNAN',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCNV99','SAI BALA FRESH SUPERMARKET-ITD',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCCOM3013','JANAKI STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFC3','ROYAL TREAT JUICE SHOP',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFC4','VADA POCHE FRESH JUICE',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF1','BLOCK DOT',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF10','SRI NEEVI UDHAYAM COOL BAR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF11','HUNGRY PANDAA JUICE & SNAKS',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF12','RIO CAFE JUICE SHOP',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF13','THAI JUICE',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF14','BIFRAA FRESH JUICE',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF15','FRESH JUICE BAR',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF2','D EAT JUICE SHOP',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF5','R.R.TEA & JUICE CORNER',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF6','JUICE CLUB TEA STALL',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF7','SUMATRA HOTEL',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF8','GOOD DAY CAKES',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCDFCF9','RIO CAFE',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED1','MOHAN COOL BAR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED10','SIVA GEETHA AAVIN MILK',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED11','M.K.MANI STORE(OPLM) -B',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED12','MADEENA COOL BAR-PAL',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED13','V.M.S COOL BAR PVM',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED14','C.G SHELKH COOL BAR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED15','SRI VENKATESHWARA COOL BAR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED16','HASHIK MILK BAR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED17','LAKSHMI COOL BAR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED18','J.J. STORE(POL) -B',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED19','APN TEA COOL BAR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED2','CHANDRAM TEA SHOP',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED3','ROETHKA COOL BAR (AKP)',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED4','SHUBAN MEDICALS',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED5','D EAT TEA STALL',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED6','A.K.BABU CHANDRAN TEA STALL',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED7','R.K BOMBAY TEA STALL CHR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED8','SRI SAI ICE CREAM (CHR)',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCED9','SWETHA COOL BAR',2,4
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCF18','SELECTION FANCY & COVERING_PLVM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCF19','VAISHALI FANCY_PAMMAL',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS1','ANNAIMANI FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS10','CITY BOOK CENTER & FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS11','AMBKA FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS12','THANGAM GENERAL STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS13','LAKSHMI STORE-CHROMPET',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS14','SRI MADHAJI FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS15','JAI SHRI GANGA STORES',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS16','SUN FANNCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS17','PONS SHOPPY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS18','LATHA FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS19','APPLE MEDICAL - TVM',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS2','J.J.STORE-AKP',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS20','MAHA LAKSHMI STORE (CHR) -A',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS21','SAI FANCY(CHR) -B',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS22','LAKSHMI STORE-CHR',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS23','KRISHNA FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS24','MUMMY CHOICE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS25','TAAJ FANCY STYLE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS26','HAKKIM READYMADES',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS27','7 STAR FASHION JEWELLERS',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS28','SUN ENTERPRISES',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS29','NARAYANAN STORE -OPLM',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS3','ADITHYAN STORE(ANK) -A',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS30','TRENDZ',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS31','RAM DEV FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS32','KRITHIK FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS33','AARA FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS34','RAJAN STORE(O.PLM) -B',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS35','MASS FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS36','ASMA FASHION JEWELLERY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS37','HUNTER GARMENTS',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS38','SANJANA FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS39','BLESSING FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS4','KJS FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS40','JOY FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS41','MADHA DEPT',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS42','JAYA CHANDRAN(PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS43','SHOPPEE & SHOPPEE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS44','SHANTHI FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS45','SUMANGALI BANGLES',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS46','SRI PRIYA BABY LAND-PAL',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS47','MANGAI GOLD COVERINGS',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS48','MUMMY DADDY FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS49','SUSI FANCY (PML) -B',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS5','VIJAY FANCY.',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS50','RANGAN STORE PML -A',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS51','ARC FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS52','ROJA FANCY STORE(POZ)',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS53','SUHANI FANCY STORE_AKP',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS54','J. P. FANCY_NAN1',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS6','JP FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS7','MODERN STATIONARY.',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS8','HABIBHA FANCY',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCFS9','BISMI BOOK CENTER',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCG4001','ARASU STORE.',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1','MURUGAN STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR10','AYYANAR STORE (AGARAM)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR100','NARAYANA STORE (CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1000','BALA MURUGAN STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1001','GOVINTHAN STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1002','JAI SELVA GANAPATHY STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1003','SUMATHI TEA STALL - WTBM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1004','JEBA STORE - WTBM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1005','MAKESH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1006','NATARAJA STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1007','RAJA PROVISION',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1008','VANITHA STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1009','M.V.PROVISION',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR101','MADHA STORE -2  ( CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1010','BALAVIGNESH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR10100','SRI SAI SUPER MARKET',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1011','PANDIAN STORE - W.TBM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1012','RAJA SEEVAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1013','R.S.D STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1014','KURUNJI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1015','ROOPINI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1016','PANNER SELVAM STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1017','SAMUNDIESWARAN STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1018','SRI RAM NEWS MART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1019','SUBHAM MART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR102','BALAJI STORE(CHEM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1020','KUMARAN STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1021','S.K STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1022','SABEER STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1023','KAMALA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1024','KRISTOPER STORE - AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1025','SELVA VINAYAGA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1026','CHANDRA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1027','ABIRAMI TRADERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1028','RAJA STORE-TRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1029','S.MARI SELVI STORE (TMI)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR103','SAMUEL STORE (CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1030','GURUMOORTHY STORE-TRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1031','MURUGAN STORE-PAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1032','CHELLIAMMAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1033','SULOKSON STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1034','LAKSHMI STORE(TRM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1035','GURUMOORTHY STORE(TRM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1036','HOT PUFFS & CHIPS-TRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1037','YOGESWARI  STORE-TMVKM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1038','NOOR PROVISION STORE(TRM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1039','RAJA STORE (TRM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR104','JEEVA STORE(CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1040','SAFIYA STORE(TRM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1041','RAVI STORE-TRM-ANNA POORNI TIFFEN CENTRE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1042','DHANUSHYA STORE(TMK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1043','SRI AYYANAR STORE-',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1044','NAVEENA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1045','SSS MALIGAI KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1046','SRI MATHAJI PROVISION-TRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1047','MADAN STORE(TMR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1048','MATHIALAGAN STORE(TRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1049','ANSARI STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR105','NEW PONNU MARKET{CHE}',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1050','JJJ STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1051','SHIVA STORE (TMR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1052','OM SAKTHI PROVISION STORE ( CHE )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1053','MAHARAJA STORE(VGVL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1054','DINESH KUMAR STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1055','A.G.STORES -VGSL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1056','JAYA STORE - VGSL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1057','CHITRA STORES - VGSL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1058','AANDAVAR STORE - VGL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1059','B.V.STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR106','DHANA SINGH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1060','SUSHMITHA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1061','SRI SIVA SAKTHI STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1062','JOY FRUIT AND VEG',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1063','LALITHA SUPER MARKET (VGL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1064','SRI KRISHNA PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1065','THANGAM SUPER MARKET(VGVL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1066','KANNAN STORE (VGS)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1067','KIRUTHIKA STORE (VGS)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1068','GM STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1069','A.M TRADERS (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR107','P.S.PANDIAN HOME NEEDS',2,9
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1070','SRI LATHA STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1071','ANNAI STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1072','AND GO STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1073','SELVA AARSAU STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1074','K.NAVEEN STORE(VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1075','AZHAGUSWAMY STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1076','AYYANAR STORE (SPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1077','JAI SNACKS (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1078','SURIYA STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1079','THIKSHIKA STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR108','VALLI MEDICALS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1080','AYYANAR VEGITABLE STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1081','SHAHARAS COOL LAND & FRESH JUICE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1082','RAJAN STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1083','ANNAI STORE (W.TBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1084','S.S.STORE (MGR ST) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1085','THIRUMURUGAN STORES-O.PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1086','AJANTHA NEW SWEETS(Z.PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1087','KAMARAJ STORE(Z.PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1088','MURUGAN STORE(Z.PLM) -SC',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1089','MUTHARAMMAN STORE(Z.PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR109','PREAMJI BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1090','PADMAVATHI SRI GEN.STORE(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1091','PON LATHA STORE(ZPLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1092','PUSHPALATHA STORE {O-PLM} -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1093','SARAVANA STORE(Z.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1094','VIJAYA LAKSHMI PROVISION STORE(ZPLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1095','KRISHNA PROVISION {O-PLM} -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1096','SRI VINAYAGA STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1097','CHITRA STORE-NEMILICHERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1098','SUMITHRA MALIGAI {O-PLM}',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1099','PACHAIAMMAN STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR11','KALAISELVI STORES (AGARAM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR110','JAI JAGATHAMBAL STORE(ETBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1100','KALANJIYAM RICE STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1101','JAYA STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1102','A.M TRADERS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1103','FATHIMA MAHALIR RICE KADAI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1104','SRI AMBIKA STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1105','SRI JAYALAKSHMI STORE1',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1106','EBENEZER STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1107','RUCHIKA STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1108','KARTHIKEYAN STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1109','NAVEEN STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR111','SRI SRINIVASA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1110','SARAVANA STORES-.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1111','SHREE GANESH GENERAL STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1112','SRI MARUTHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1113','JKS STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1114','KARPAGAM STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1115','NR SARAVANA COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1116','A.M STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1117','JEEVA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1118','ANITHA STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1119','IRASTH STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR112','SRI VELMURUGAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1120','GANESH NEWSMART',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1121','AMR COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1122','M.S VELAVAN COOLBAR & STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1123','SHAJAHAN COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1124','RAJAN STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1125','JESSINA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1126','GN COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1127','GANESH STORE2',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1128','RASOOL STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1129','SRI SANDHIYA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR113','SRI MUTHU RAJA STORE - CPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1130','IRFAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1131','ANBU STORE 1',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1132','BARANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1133','SUYAMBULINGAM STORE - 9941765174',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1134','SRI RAJA HARI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1135','VELAN RICE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1136','PAUL MILK CENTRE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1137','NEW MARY STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1138','ANANDHAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1139','LU LU EXPRESS- 8925482455',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR114','DEVID STORE CPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1140','NEW THANGAM STORE..',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1141','SRI KUMARAN VARUKADALAI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1142','SRI JAYAM DEPT. STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1143','G T R STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1144','THIRUCHENDUR VELAVA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1145','KASHURIBA WOMENS CONSUMER CO-OP.STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1146','JAYAM SELVAM STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1147','JK SUPERMARKET',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1148','S.M STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1149','KOWSHIK STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR115','SRI MURUGAN PALAMUTHIR SOLAI (CPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1150','GANESH PATHANJALI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1151','GOWRISHANKAR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1152','V.S VASU RISE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1153','GANAPATHI OIL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1154','GANAPATHI RICE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1155','MASDHAN RICE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1156','J52  SUPER MARKET',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1157','R.P PAULDURAI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1158','SRI THANGAM STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1159','SHREE MURUGAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR116','RAM DEV PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1160','ASRIN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1161','C.M MUTHLIYAR NATTUMARUNTHU KADAI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1162','NEW SABEETHA.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1163','YUSAF STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1164','ABRAHAM STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1165','SHABICK STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1166','SELVI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1167','RAJESHWARI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1168','SATHYAM VEGITABLES SHOP',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1169','R.D.K DAILY FRESH',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR117','M.K.RETAIL SOLUTION',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1170','SANTHOSH FOOD...',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1171','R.R STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1172','JAYAVEL STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1173','SK MALIGAI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1174','LAKSHMI STORES..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1175','VIJAYA STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1176','SRI GANESH STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1177','NEW SARAVANA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1178','MUMMY DAIRY...',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1179','A M AYYANAR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR118','AMBAL TRASERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1180','L.R.MALIGAI',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1181','SRI JAYARATHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1182','CHITHIRAI GANI STORE 2',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1183','SRI DURUVANA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1184','DHARMA RAJ STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1185','SRM STRORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1186','A.K STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1187','VENKATESH COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1188','SRI GANESH STORE1',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1189','ISAK STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR119','M.K.STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1190','NEW PRIYA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1191','GAYATHIRI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1192','EZHILARASI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1193','RAMAJAYAM STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1194','SARASWATHI STORES.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1195','SI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1196','SENTHURMURUGAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1197','SRI SAKTHI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1198','PARAS STATIONARY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1199','MURUGESH STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR12','BEST SNACKS (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR120','DEEPA GEN STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1200','SELVA PUSHPA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1201','S.T STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1202','NEW SELECTION STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1203','RANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1204','JAYA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1206','NATHAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1207','AKSHYA TRADERS...',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1208','MUTHU MANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1209','SARA STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR121','LUCKY MOBILES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1210','NATARAJAN STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1211','RAJ PROVISION-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1212','SHIPANA STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1213','SRI DEVI KARUMARI AMMAN STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1214','TAMIL NADU PROVISION-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1215','S B PROVISION',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1216','NEW JAYALAKSHMI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1217','MINNAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1218','OM SHANMUGA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1219','SELVAM STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR122','INDHRA MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1220','PERIYANDAVAR STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1221','NEW ANANDHI STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1222','NANDHINI STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1223','DANIAL STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1224','LINGAM STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1225','BALAN STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1226','ROBIN STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1227','PARVATHY STORE 2 .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1228','RAJI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1229','MANIVANNAN STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR123','THIRUMALAI STORE (CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1230','VIJAYARANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1231','NEW JAYA STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1232','GEETHA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1233','MANI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1234','PALANIVILAS STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1235','PAPPA STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1236','PARAMESHWARAN COFFEE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1237','SIVALO AYYANAR STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1238','LOGU STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1239','LINGAM STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR124','ANNAI STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1240','MAMTHA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1241','MAHA LAKSHMI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1242','PALANI VILASGHEE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1243','JAYALAKSHMI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1244','NEW NELLAI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1245','AMBIKA OIL STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1246','NEW ANDROO STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1247','PETER STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1248','CAWIN TRADERS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1249','GERALD STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR125','OM SAKTHI COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1250','KEERTHANA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1251','AYESHA PROVISION',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1252','SRI LAKSHMI STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1253','GANESH RICE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1254','SRI SAKTHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1255','RAJESWARI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1256','SRI PARASAKTHI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1257','SUBRAMANIAM RICE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1258','SRI MURUGAN STORE KESARI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1259','SRI MURUGAN STORE PARTHASARI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR126','RAJA HOT & CHILL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1260','SRI KUMARAN STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1261','LAKSHMI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1262','LINGAM STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1263','SENTHIL STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1264','DHARSHINI TEA STALL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1265','SRI VELU STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1266','ANANDHAKANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1267','SMY STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1268','SRI VETRIVINAYAGAR STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1269','SANTHANAMARIAMMAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR127','SRI BALAJI TRADERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1270','MN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1271','SUN STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1272','THIRUMALAI SRINIVASA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1273','NELLAI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1274','MUMMY DAIRY-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1275','RAJ STORE NATUMARUTHU',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1276','PANDIYAN STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1277','SARAVANA STORE ..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1278','THANGAKANI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1279','VEL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR128','SRI KRISHNA STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1280','MUTHARAMMAN STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1281','ANBU COOL BAR.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1282','SAKTHI RICE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1283','JEBAMANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1284','MS PANDIYAN STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1285','ANAND PROVISION',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1286','BALAN PROVISIONSTORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1287','CHELLAM STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1288','REENA SHOPPING',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1289','DEVI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR129','ISAKIAMMAN STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1290','VIJAYALAKSHMI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1291','SK STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1292','KOKILA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1293','LINGAM STORE 2.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1294','BALAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1295','PALANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1296','K M S STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1297','DASS STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1298','SARASWATHI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1299','LIPTON STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR13','RAMDEV PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR130','ANITHA STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1300','TAMILNADU MALIGAI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1301','SRI DEVI STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1302','VIGNESH OIL STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1303','SRI HARI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1304','ARSHAT STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1305','MN PROVISION',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1306','DEEN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1307','DHANALAKSHMI STORE. ALAN',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1308','KALI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1309','BREAD TALK',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR131','APPLE DEPARTMENTAL STORE - TVM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1310','SRI RAM DAIRY-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1311','GR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1312','LAKSHMI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1313','JEBA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1314','NEW ARIYABHAVAN.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1315','BALAMBIGAISTORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1316','NEW SENTHIL STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1317','RKS STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1318','BHAVANI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1319','MURUGAVEL RICE&OIL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR132','S.S.P ENTERPRISES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1320','ANNAI STORE;',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1321','ANBUMANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1322','SRI BALAGANAPATHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1323','HARI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1324','MURUGAVEL STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1325','DURAI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1326','SRINIVASA POOJA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1327','RAGHU&SASI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1328','SUDERASAN STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1329','CHITHIRAI GANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR133','JOLLY SNACKS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1330','SAHAYAM STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1331','DHANALAKSHMI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1332','RAJESWARI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1333','NEW AMBAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1334','SRI PARASAKTHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1335','MAHARAJASEEVAL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1336','SOBANA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1337','SRI SAKTHI  STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1338','JANAKI NEWS MART',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1339','SARAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR134','V.M.STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1340','UMA COFFEE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1341','VELANKANNI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1342','AYYANAR STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1343','RATHANA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1344','PRAKASH STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1345','DAVIDU STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1346','SUYAMBILINGAM STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1347','SRI LAKSHMI TRADERS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1348','GRACE STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1349','RAJI STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR135','THIRUMAGAL ICECREAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1350','JAYAMURUGAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1351','RAJA STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1352','GAYATHRI STORE 2',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1353','SIVAGAMI STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1354','SRI MURUGAN STORE ..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1355','SHREE PARVATHI STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1356','AR SEEVAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1357','SRI MAHESHWARI OIL.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1358','SRI MURUGAN STORE LP...',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR136','THIRUMAL STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1360','CHIDAMBARAM STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1361','SKM STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1362','MURUGAN NEWS MART.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1363','MANONMANI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1364','MURUGAN RICE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1365','AYANAR STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1366','AMMAN STORE 1',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1367','SRI MURUGAN STORE (SUREN)',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1368','SIVASAKTHI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1369','STAR STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR137','V.R.M STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1370','SRI BALAJI COFFIEE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1371','SRI  KARUMARI AMMAN.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1372','RJ SEEVAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1373','MOOKIYA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1374','MJ STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1375','CHINNA THAI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1376','KANI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1377','K.A. SHANMUGAM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1378','JAYAMANGALAM STORE',2,9
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1379','SUYAMBULINGAM STORE&BAKERY.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR138','SIVA STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1380','PON RANI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1381','ANANDHI STORE.FC',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1382','L.R. DEPARTMENTAL STORES',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1383','L R STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1384','VENKADACHLAPATHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1385','SUNDAR GENERAL.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1386','ARAFA PROVISION',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1387','ANBU STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1388','MARY STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1389','RAJA STORE 2.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR139','DHANALAKSHMI STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1390','JAYA BHARATHI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1391','JAYALAKSHMI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1392','SRI MUTHUMARI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1393','SHREE MURUGAN STORE 2',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1394','GNANAM STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1395','JK STORE .',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1396','ANDROO STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1397','SRINIVASA HOME NEEDS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1398','EBINIAZAR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1399','BAGYALAKSHMI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR14','IMMANUVEL STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR140','ABIRAMI STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1400','MUTHUMALAI AMMAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1401','SAKTHI GOPIGA.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1402','VINAYAGA STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1403','AYESHA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1404','NAZIR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1405','SATHIYA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1406','THANGAM STORE ..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1407','THIRU SENTHIL ANDAVAR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1408','GANI STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1409','VETRIVEL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR141','ALAGU PROVISION (CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1410','SRI SAKTHI STORE ..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1411','RAJAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1412','OM SAKTHI ICE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1413','RVS COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1414','KUMARAN STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1415','OM SAKTHI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1416','SAKTHI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1417','VALLIAMMAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1418','VEEBISH & VISHAL RICE SHOP',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1419','SAKTHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR142','AMUTHA STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1420','AYYANAR STORE - GUINDY-9566215650',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1421','KUMAR STORE -GUINDY(ANS)-9150116141',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1422','NEW BISMILLA - VELACHERY - 9994535901',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1423','SRI MURUGAN STORES-MADUVAN',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1424','BHARATH STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1425','JAGADESH STORE-9551124449',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1426','SIVA PERUMAL STORE-9962392763',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1427','SIVA STORES - GUINDY-9444844628',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1428','SUNDARAMBALSTORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1429','PARVATHI STORES - GUINDY-9941467678',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR143','G.K.R.PROVISION (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1430','SARAVANA STORES-7401062744',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1431','V.M.K.E. MALIGAI - 9710708547',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1432','VP STORE-9840531861',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1433','SRI PANDIYAN PROVISION STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1434','SATHYA STORE - 9176763679',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1435','LAKSHMI MALIGAI STORE - 9952915633',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1436','NEW ANJALI SWEET&BAKERY(GUNDY)-9677015608',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1437','NEW JAYARAM STORE - GUINDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1438','PARVATHI STORES-9840318310',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1439','PATTU GENERAL STORE-044-22444170',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR144','JAYABAL STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1440','PRETHIKA STOTE-GUINDY-996247004',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1441','RAJU STORE -GUINDY-9677516499',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1442','SELVA GANAPATHY STORE-044-22553474',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1443','PONVANDU IYYANAR STORE -GUINDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1444','VINAYAGA STORE - 8754554077',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1445','SRI VENKATESHWARA PALAMUTHIR SOLAI- 9842158083',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1446','LAKSHMI STORES-CHECKPOST-9500032866',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1447','NELLAI STORE - GUINDY-044-22551153',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1448','MURUGAN STORE-044 22550752',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1449','SRI MARIEESWARI STORE- 908001143',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR145','LAXMI STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1450','V.AMMAN STORE- 8056822021',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1451','KURUNJI MALIGAI-9677333106',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1452','MURUGAN STORE -GUINDY-9884173017',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1453','ELLAPPAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1454','PS STORE(US)',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1455','KARTHIKA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1456','ANNA POORNA DEPT STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1457','JAYA SHIVANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1458','SRI RAMDEV PROVISION',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1459','AASHIKA FRUITS & VEGITABLES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR146','MURUGAN STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1460','RAJ STORES.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1461','GREEN SUPER MAARKET',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1462','E.BABU MALIGAI - 9952981622',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1463','MARIEESWARI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1464','SRI SAKTHI STORES.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1465','BISMI STORE GUINDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1466','HARSHATH ENTERPRISES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1467','RAMALAKSHMI STOER- 9940468510',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1468','FATHIMA STOREMPM-9841603125.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1469','KARTHICK STORE(MBM)-9841266494.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR147','RAJAN STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1470','SANGLI STORE(MBM)-9840733933.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1471','GEETHA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1472','RD STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1473','MOOSA SNACKS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1474','CHENNAI PROVISION...',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1475','MONISHA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1476','THANGARAJ STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1477','AMSHA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1478','K.K.N.SUPPLIERS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1479','R.L.H.STROE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR148','S.K.M STORE(CHR)1 -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1480','SRI BALAMURUGAN RICE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1481','RAJA RICE MANDY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1482','GOPAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1483','DEVI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1484','AAVIN FOODS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1485','SRI SIVASAKTHI DEPT STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1486','VIJAYARANI STORE 2',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1487','PARVATHI NEWS MART',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1488','KAMATCHI STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1489','CHELLAMUTHU COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR149','PRABU STORE CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1490','MANOJ STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1491','BEST & BEST SUPER SHOPPE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1492','SRI SAI BABA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1493','ASNA MAGA MARKET',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1494','ANANDHA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1495','OM SHOPPEE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1496','AMMAN STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1497','SREE KAMAKSHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1498','ANNAI STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1499','RAJA SEEVAL STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR15','THE PURE & SURE SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR150','MURUGAN STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1500','BAAVA SEEVAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1501','VIVEKA STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1502','AYYA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1503','SELVALINGAM STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1504','JAYAM STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1505','SHANTHI COOL BAR.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1506','COOL CLUB',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1507','MUTHARAMMAN STORES.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1508','VIGNESWARA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1509','JEGAN STORE...',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR151','THIRUMURUGAN STORE-HAS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1510','VINOTH MILK',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1511','DURAI RICE STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1512','HOT CHAPPATHI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1513','GURU STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1514','VELAN STORE(VS)',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1515','BAKIYALAKSHMI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1516','SAI RAM HOT CHIPS- COLL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1517','SAIRAM HOT CHIPS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1518','UTHAYA ENTERPRISE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1519','SRI AYYA MALIGAI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR152','GANAPATHI STORE- A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1520','DASAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1521','R.B AMUTHVALLI COOL BAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1522','AYYANAR CHIPS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1523','SANJANA MINI MART',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1524','KUMARAN STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1525','JEEVATHIPATHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1526','SS NATTU MARUNTHU KADAI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1527','LAKSHMI AMMAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1528','A.S.M.IN & OUT',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1529','ALLWIN SHOPPE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR153','SELVAM STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1530','NEW JAYA STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1531','SENBAGAM STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1532','LAKSHMI STORE 2',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1533','MEENATCHI TEA STALL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1534','PRABA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1535','SK STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1536','ESWARI COOLBAR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1537','MADHA NEWS MART',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1538','PONRADHA PROVISIONS',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1539','ANANDHA STORE....',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR154','SRI BALAJI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1540','SRI SAI STORES.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1541','ARUNA STORE..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1542','AMIR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1543','SATHYABAMA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1544','PRADEEP STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1545','SREE VIJAYALAKSHMI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1546','MARIA THANGAM STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1547','SARASWATHI AGENCY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1548','SANGILI STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1549','MANIKANDAN STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1550','BISMILLAH STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1551','JAYALAKSHMI STORE...',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1552','NEW SHANTHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1553','SRI BALAMURUGAN RICE MANDI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1554','JAGANATH FOOD CORNER',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1555','JAYAVINAYAGA RICE MANDI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1556','VIJAYA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1557','GANAPATHY BOOK CENTRE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1558','KAMATCHI STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1559','BALAMURUGAN STORES.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR156','AMMAN STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1560','SRI JAGATHAMBA PROVISION STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1561','VELMURUGAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1562','MARIAMMAN STORE- 7092234490',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1563','SRI MURUGA PAZHAMUDIR NILAYAM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1564','KKP ENTERPRISES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1565','LINGAM STORE VELACHERY',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1566','ABIRAMI STORE-9444676452',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1567','ISHWARYA STORE- 9962776779',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1568','AMBIKA PROVISION.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1569','SATHIYA STORE-',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR157','DHANALAKSHMI STORE-(CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1570','SRI KAMATCHI SUPER STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1571','KAVIYA STORE.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1573','JAI GANAPATHY STORES-9043221514',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1574','SUDHA MALIGAI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1575','MAHALAKSHMI STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1576','SRI BALAJI STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1577','RAJIV STORE-9941374954',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1578','NISHA STORE - MADUVAN',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1579','RAGVENDRA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR158','A.S.STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1580','AYYANAAR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1581','VISHWA STORE-9445092296',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1582','REEBA STORE-8939245331',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1583','ELIM STORE- 9710607213',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1584','R.J STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1585','KANNAN STORES..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1586','S.K TRADERS (AMMA APPA STORE)',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1587','ASEELA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1588','AKILA STORES-044-22447256',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1589','PAVITHRA STORES VELACHERY-8754564534',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR159','GANESAN COOL DRINKS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1590','RAHMATH STORE-VELACHERY-9659251317',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1591','ANNADURAI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1592','SENTHIL STORE-VELACHERY-9841753417',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1593','JAYARAMAA AGENCIES - 7598247463',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1594','RAJA STORES..',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1595','J.S STORES',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1596','NELLAI SUPER MARKET',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1597','NEW BHAVANI PROVISION STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1598','THANGAPUSHPAM STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1599','VASANTH STORE - 9840683961',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR16','R.M.NADAR - STORE(INDRANAGAR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR160','SRI CHAITHANAYA PROVISION WORLD',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1600','VIP NACHIYAR STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1601','VM PANDIYAN STORE-9840666106',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1602','BHAVANI PROVISION-7200768678',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1603','SARAVANA STORE- 9952947922.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1604','MATHAJI PROVISION STORE- 9884797561',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1605','KALAISELVAN STORE VELACHERY 9444506524',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1606','NEELAVATHI STORE3',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1607','MANI RICE MANDY VELACHERY-8122070456',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1608','JANAKI STORE-9710860970',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1609','PUSHPA STORES- 9941461295',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR161','MURUGAN STORE-NEMILICHERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1610','DEEKSHI STORES-VELA-9884439090',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1611','RAJA STORE- 9710568843',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1612','JAYALAKSHMI STORE- VELACHEY 9841414404',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1613','AMURTHA VALLI STORE-9884140306',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1614','SRI AMMAN RICE MANDY-9941466574',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1615','LAKSHMI STORES - VELACHERY- 9840391215',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1616','D GOVINDASAMY STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1617','SARASWATHI STORE TNHB',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1618','LAKSHMI PROVISION',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1619','MUKIYA STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR162','DHANALAKSHMI PROVISION-NEMILI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1620','SRI SENTHILANDAVAR STORE-9884222319',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1621','YD MART.',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1622','BAKIYAMMAL STOER',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1623','MANAIVIZHIL AMMAN STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1624','MURUGAN STORE - 9962230471',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1625','SRI KUMARAN STORE-VELACHERY 9445787260',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1626','SRI VIJAY VIGNESHWARAR STORE- 9789817634',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1627','NAGAMANI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1628','BALAJI STORE-TNHB',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1629','AATHI MURUGAN STORE -HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR163','JB.BROTHERS SHOP & SAVE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1630','NAESEY STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1631','MAHALAKSHIMI SUPER MARKET - HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1632','UMA STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1633','SELVAGANI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1634','VENKATESWARA STORE -NGN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1635','SRI VINAYAGA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1636','MODERN STOVE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1637','MARIYAMMAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1638','M.A.GENERAL FANCY STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1639','RAJ STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR164','MUTHURAM STORE-NEMILI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1640','RAJESWARI SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1641','VENKATESAM MALIGAI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1642','KATHIRESAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1643','MASS FANCY (GANDHI)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1644','VIJAYASTORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1645','ARUN LIFE FOODS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1646','MURUGANANTHAM MALAR NILAYAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1647','RAJA SEKAR NEWS MART-MGR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1648','SRI SAI RAM HOT CHIPS -MGR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1649','CHERISH RETAIL -MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR165','VENKADESWARA STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1650','SARAVANA STORES-SEM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1651','AYYAPPAN STORE -PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1652','SARWESHWARA STORE -TRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1653','THIRUMALA IYENGAR BAKERY & SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR166','MARIEAMMAN STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR167','NEW SIVASAKTHI STORE(CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR168','ANANDA STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR169','SRI VINAYAGA TRADERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1699','VIJAYA PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR17','GANESH SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR170','CHANDRA STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1700','LINGAM STORE_CAMP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1701','GANAPATHY STORE_AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1702','NEW SANGEETHA STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1703','DEVI VEG SHOP_THRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1704','SURESH COOL BAR_TGNR',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1705','DEVI STORE_TGNR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR171','SAKTHI MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR172','J.K.STORES CHR -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR173','K.K.STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR174','KAMATCHI AMMAN STORE -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR175','KRISHNA PROVISION -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR176','KRISHNA STORE CHR -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR177','M.R.K.PROVISON STORE(CHR) (R.K) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR178','M.S.MANI STORE NIMI -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR179','RAGAVENDRA STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR18','RATHI STORE/AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR180','RAMESH NEW STORE (CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1800','SMS STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1801','RAGUL STOVE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1802','JAI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1803','RAAMANATHAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1804','PERIYASAMY STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1805','THOMAS PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1806','KRISHNA PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1807','SRINIVASA GENERAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1808','SHANMUGAM STORE-THRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1809','RAMESH-ITC',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR181','SARAVANA STORE -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1810','JANANI SWEETS & BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1811','S. KANNAN STORE_HAS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1812','SANDHIYA STORE_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1813','THIRUPATHI STORE_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1814','LAKSHMI STORES_CRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1815','SRI MAHALAKSHMI IYYENGARS SWEETS & BAKERY_CRM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1816','JEEVA STORE_HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1817','SRI KUMARAN VEG. & FRUITS_GOW',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1818','S. M. S. PROVISIONS_PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1819','ATHITHAN STORES_AKP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR182','SANKARESWARAR STORE CHR A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1820','MUTHURAMAN STORE_PLTL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1821','RAJA COOL BAR_PLTL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1822','SRI SAI TRADERS_VNVSL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1823','SRI GOLD SUPERMARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1824','THAMIZH STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1825','ARC MALIGAI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1826','SUBARAMANIYASWAMY RICE AND OIL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1827','A 1 ENTERPRISE -PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1828','NOOR SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1829','PRIYA-ITC',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR183','SRI KUMARAN STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR184','T.N.S.PROVISION CHR -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR185','KARTHICK STORE - CHR-C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1852','GOWTHAM STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1856','PANDIAN STORE (VEL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR186','SAKTHI STORE2 (NKG) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR187','PATTU PANDIYAN STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR188','VALLI STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR189','SELVAM STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR19','J.K STORE/AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR190','MAHENDHIRAN STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1900','AYYAN SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR191','SRI JAYASHREE STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR192','S.P.&SONS(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR193','CHENNAI FOOD PLAZA',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR194','CHINNA THAMBI STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR195','KASTHURI TRADER(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR196','CHITRABAKIYAM STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR197','M.R.BALAJI STORE(CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR198','R.MANIKANDAN STORE(CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1980','NELLAI KAAIKANI -SLR',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1986','A.M STORE-MGR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR199','SRI DURGA FANCY STORE(CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR1999','AYYANAR NATTU MARUDHU KADAI',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2','RAJ TIFFEN CENTRE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR20','SARAVANA STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR200','SATISH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2000','PON VINAYAGA STORE(ZPLM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2002','LOKESH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2003','M.H.S STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2004','SRI MURUGAN STORES (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2005','CHELLAPPA STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2006','SEETHALAKSHMI STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2007','NEW PRABA STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2008','SRI LAKSHMI STORES (CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2009','VENKATESAN MALIGAI STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR201','BRAHAMMA SAKTHI STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2010','H.N GENERAL STORE (SHOPPING COMPLEX)',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2011','PREMA STORE (RKM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2012','AZHAGAR  STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2013','SHRI VAARI TRADERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2015','KARTHICK FRUITS & VEGETABLE SHOP',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2016','SRI LAKSHMANA SAKTHI COOL BAR',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2018','V.V.S STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2019','SRI AYYANAR STORE(CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR202','EBIN STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2028','NIRENJANA RICE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2029','GNANAM STORES-CPM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR203','ISAQ STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2030','MUTHU RAJ STORE-CPM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2031','JEBA JEYAM',2,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2039','SURESH SEEVAL  STORES-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR204','JAYACHANDRAN STORE -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2040','SRI AMMAN STORE-VEL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2041','NITHESH TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2042','VIGNESHWARA STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR205','KANDAN STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR206','MUTHARAMMAN SRI STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR207','MUTHU LAKSHMI MALIGAI (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR208','PERIYASAMY STORE -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2085','SHREE AKSHAYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR209','PRADEEP STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2095','GRACE STORE2',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR21','S K A STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR210','PT.STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2103','J.S. TRADESR PROV STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2104','MUTHARAMMAN STORE (THRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2106','PRABHU STORE (ADKM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2107','MUBARAK STORE (ALR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2108','PARVATHI STORE(T.G NGR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR211','SHANTHI STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2110','PONRADHI STORE (OPLM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2111','SUBBHAIYA STORE (OPVM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2112','KANAGARAJ STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2113','PARVATHI STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2114','SARAVANA STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2115','SRI SELVA VINAYAGAR STORES_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2116','NEW SARAVANA STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2117','ARI AMBIKA PROVISION_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2118','NEW MURUGAN STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2119','SRI VENKATESWARA STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR212','V.A.S STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2120','KARTHIVEL AYYANAR STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2121','A.M SNACKS(OPLM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2122','BALAJI BAKERY & SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2123','SRI RAMAJAYAM STORE(POZ)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2124','VASANTH TEA STALL(CPVM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2125','AL NOOR TEA STALL (CPVM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2126','SHREE ASHWINI SWEET & BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2127','ANNAI PROVISION (SEM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2128','VEL MURUGAN STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2129','ANBU STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR213','VANAJA STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2130','AISWARYA STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2131','EVER GREEN SUPER MARKET_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2132','RAJA STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2133','SRI GOKULAM PROVISION STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2134','NEW MUHAMMED RIZWAN STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2135','SRI THAYAR POOJA STORE_CHITLAPAKKA',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2136','NEW LINGAM STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2137','K. B. STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2138','SRI SAI TRADERS_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2139','KAMATCHI AMMAN STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR214','S.MARI SELVI STORE {CHR} -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2140','SRI SABARI STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2141','RAMESH STORE_HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2142','SRI AMBIKA PROVISION_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2143','ANNAI PROVISION STORE_AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2144','SASI STORE_SLR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2145','SUNDARAJAN PROVISION STORE_SLR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2146','LAKSHMI STORE_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2147','PRAJIN STORE_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2148','ASWATH STORE_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2149','TWINA STORE_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR215','MEENATCHI STORE {CHR} -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2151','BUDJET BAZAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR216','JOHNCY STORE(SAN} -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR217','PAVITHRA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR218','CHELLAM AGENICES(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2189','NEW BUDJET BAZAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR219','SUBHA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2190','SRI MARIAMMAN STORES (NAN)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2191','AKSHAYA SWEETS (MED)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2192','THANGA PANDY NADAR STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2193','PARVATHI STORE (NANG)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2194','BALU NAATU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2195','THIRUMAGAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2196','SRA NAATU MARUNTHU KADAI (PVM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2198','SIVA STORE (MNM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2199','SREE BALAJI IYENGAR BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR22','MURUGESAN STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR220','JAYARAM MITTAAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2200','VISIT MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2201','ARUNACHALA NEWS MART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2209','VAISHNAVI SUPER MARKET (NGK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR221','SUBESH SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2211','MURUGAN STORE(CHRMT)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2212','MUTHU 2 STORE (NGK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2214','AYYANAR STORE 9NGK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2216','B. VIJAYA STORES (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2217','FARRIS RICE MANDI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2219','NIRAIMATHI STORE (TNRI)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR222','VSP TEXTILE ICE CREAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR22213','VETRIVEL STORE (NGK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR223','CHROMPET ICE LAND',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR224','JOTHI RAJAN STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR225','RAJA STORE (CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR226','VSP OIL MILL PROVISION(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR227','AGALYA STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR228','ARCHANA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR229','SRI VASAVI STORE -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR23','MUTHARAMMAN STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR230','BABY STORE HPM -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR23010','SRI GANAPATHI SWEETS & BAKERY-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2309','CIYON STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR231','BALAJI STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2310','SRI S.M.FANC & GIET WORLD',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2311','SAKTHI GENERAL STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2312','ESHAAN TRADER',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2313','SRI MURUGAN STORE(VANU)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2314','CHENNAI SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2315','SRI DURGA NATTUMARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2316','MAHALAKSHMI POOJA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR232','CHELLAM BEEDA STALL (CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2320','PAVI SRI STORE_AGARAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2321','GNANAM DEPARTMENTAL STORE_CHIT',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2322','THAMIZH STORES_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2323','KANI BHUVANESWARI STORE_HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2324','DEVI STORE_CHRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2325','M. R. PAZHAMUDHIR_RNG',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2326','NEW NELLAI STORE_ALR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2327','DAILY NEEDS_OP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2328','JAM JAM MALIGAI STORE_OP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2329','RASU STORES_CHRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR233','CHELLAM COOL DRINKS CHR- B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2330','ORANGE JUICE PARK_THRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2331','GRACE STORE_THIRUSULAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2332','AMMAN STORE_AKP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2333','JAYAM STORES_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR23334','DHANALAKSHMI STORE_POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2335','SELVA VINAYAGAR STORE_AKP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2336','JOTHI STORE_OP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2337','PANDIYAN STORE_PVM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR234','KARUR NEI STORE CHR -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR235','MIRBAHA STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR236','S.T.COOL BAR -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR237','SAKTHI MALIGAI (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR238','TKJ STORE (CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR239','KASTHURI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR24','DHEVAKANI STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR240','SARAVANA BAKRY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR241','HARINI STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR242','SRI AKSHAYA BAKERY-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR243','PERUMAL BAKERY CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR244','J.P. STORE ( CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR245','THAMARAI STORE (CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR246','BHAGAVATHI STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR247','COLOMBU STORE(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR248','DASAN STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR249','G.M.ICE CREAM BAR -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR25','ARUN STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR250','HARIKRISHNAN ICECREAM BAR(CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2500','UNITED BLOOM ENTERPRISES LLP',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2501','SRI KARPAGAA STORES(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2502','SREE BALAJI PROVISION STORE(O.PALR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2503','SENTHIL STORE(ANPR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2504','SM TRADERS(R.NAGAR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2505','BACKIAM STORE(R.NAGAR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2506','PANDIAN SUPER MARKET(CHRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2507','NALAM ANGADI(HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2508','VINAYAGA SUPER MARKET(HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2509','MATHINA FANCY(CHRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR251','IYYANAR STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2510','PERIN SUPER MARKET(E.TBM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2511','GATEWAY C & E',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2512','A.S.T TRADERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2513','AMMAN STORE(BV2)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2514','SUBASH STORES - RNG',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2515','SIVA GANESH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2516','PRIYA  STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2517','NILGIRIS(KARTHIKEYAN ENTERPRISES)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2518','SRI SEETHALAKSHMI SUPER MARKET(T.SAN)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2519','SRI MURUGAN STORE (ZION OPPOSITE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR252','JAYA STORE (CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2522','SRI MURUGAN STORE(ZION OPPSITE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2523','ASMIYA STORES(MKBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2524','VIJAYALAKSHMI STORE(MKBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2525','V.K.P STORE(CHRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2526','MUTHU STORE(CHRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2527','JAYALAKSHMI STORE(O.PLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2528','SRI BALAJI BAKERY & SWEETS(O.PLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2529','MUTHUVELAN STORE(THRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR253','MAHA LAKSHIMI STORE -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2530','KUMAR TEA STALL(NGK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2531','PUNNAGAI STORES(THRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2532','SHAKTHI MEDICAL(SEL)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2533','SAKTHI MEDICALS(SLR)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2534','PERIYANDAVAR STORE-BV',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2535','SK FANCY STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2536','DASS STORE-NAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2537','SRI MARIAMMAN STORE-NAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2538','RAJ STORE-NAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2539','VIVEKA STORE-NAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR254','PNR STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2540','BALA MURUGAN STORE(PAMMAL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2541','E. R. STORE-POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2542','SRI AYYANAR STORES-PAMMAL',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2543','OM SAKTHIVEL FANCY STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2544','SIVA SAKTHI STORE_PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2545','SRI GANAPATHY SWEETS & BAKERY HPM',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR255','SEKAR STORE (CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2556','MAHALAKSHMI PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR256','SHAKTHI STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2561','SRI KAMACHI STORES-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR257','SRI BALAJI COOL BAR -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR258','UDAYAM STORE(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR259','BALAN MALIGAI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR26','K.R PRASASH MILK HOUSE-SLR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR260','MURUGAN SUPER MARKET(HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR261','VIJAYA STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR262','JAYA STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR263','JAGAN STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR264','B.S MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR265','JOTHI PHARMACY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR266','SRI RAJESWARI MEDICALS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR267','SURESH SEEVAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR268','SRI GENERAL STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR269','SRINIVASA STORE(CHR) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR27','JEMMY STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR270','T.K.S.PROVISION CHR -DE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR271','JAYAM PROVISION (CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR272','NEW ANANTHI STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR273','MANNA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR274','THANGAIYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR275','ANBU STORE - (CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR276','OM VINAYAGA MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR277','T.DEVARAJ CHETTIYAR NAATU MARUNDHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR278','SABITRI PROVISION SHOP-NGN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR279','A.KESAVA MUDILAYAR & SON',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR28','ANANDHI STORE/AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR280','HARI SEEVAL STORE(CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2801','S. G. STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR2805','J.M store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR281','SWATHI SEEVAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR282','ARASU STORE (CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR283','NEW CORNER FANCY (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR284','SRI BALAJI POOJA-NAATU MARUNDHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR285','THIRUMALAI STORES (CHRT)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR286','J.SAKTHIVEL PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR287','SRI SUYAMBULINGA SWAMY NAATTU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR288','BALAJI SEEVAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR289','SHANMUGA STORE HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR29','VSV ENTERPRISES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR290','REDCART PVT LTD',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR291','ARUN STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR292','DAKSHANAMOORTHY STORE (TRM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR293','MUTHU STORE (CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR294','S.K.M.TELECOM (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR295','SIVA STORE CHR -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR296','KAMARAJ HOUSE CHROMPET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR297','HIGH GLOW FANCY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR298','NARESH FANCY (CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR299','JAYAM PROVISION STORE (CHR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3','SRI GANGA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR30','HASAN BOOK CENTRE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR300','S.M.PROVISION(CHR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3000','THANKSIK STORE(PAM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR30001','MADHA STORE-PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR30010','RAJENDRAN STORE(SLR)',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR300101','RAM STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR300102','DHANALAKSHMI PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR30011','RAM STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3002','PADMAVATHY RICE-PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR30026','MATHINA SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3003','MUTHUSTORE(2)-CLC',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3004','OM MURUGA CATERING SERVICE & MESS(SLE)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3005','SRI SIVA SAKTHI STORE(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3006','AADHISIVAM PROVISION STORE(POZ)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3007','SRI AMMACHAR NATTU MARUTHU KADAI(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3008','SATHIYA PLASTICS & ESSENCE(AKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3009','SAMSUDEEN MEDICALS(PLM)',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR301','SR GENERAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3010','NELLAI KAAIKANI ANGADI(SLR)',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3011','SUKRA MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3012','SRI KAMACHI PROVISION STORE(SLR)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3013','SUBRAMANIAM NEWS MART(CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3014','SRI KUMARAN STORE(CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3015','MAGIZH DEPARTMENT STORE(CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3016','SWARNA BALAJI NEW SUPER MKT(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3017','SRI ANNALAKSHMI RICE TRADERS(CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3018','ROYAL TREAT(THRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3019','S.S.STORE(CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR302','BHAGAVATHI RICE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3020','APPLE MART(THMKM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3021','GIRI STORE(THRMKM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3022','HOT PUFFS & CHIPS 1(THRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3023','PRABHA STORE(VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3024','KANNAN STORE(GOW)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3025','CHITRA COFFEE_NAN',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3026','KUMAR STORES-CHITLAPAKKAM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3027','SRI AMMAN TRADERS_MDM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3028','BALU STORE_MDM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3029','SAI VASANTHAM STORE_RAJAKILPAKKAM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR303','SIVA MURUGAN STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3030','SRI SRINIVASA SUPER MARKET(AKP)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3031','AGAI AGROS_RAJAKILPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3032','M. K. PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3033','LAKSHMI HOT PUFFS-II_MADAMPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3034','BALA GANESH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3035','CITY PALACE HOT & COOL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3036','HEMA GENERAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3037','THENDRAL PALAMUDHIR CHOLAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3038','OM SAKTHI STORES_CHITLAPAKKAM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3039','NANDHANA STORE_OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR304','MURUGAN STORE CHROM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3040','THANESH VEG SHOP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3041','MANOJ COFFEE AND TEA SHOP_CHRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3042','S.V.R STORES_OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3043','ARK ENTERPRISES_PLTL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3044','NIVETHA STORE_HPM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3045','J. K. NATTU MARUNDHU KADAI_AGRM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3046','JAYA NATTU MARUNDHU KADAI_AGRM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3047','ASWITH STORE_MDM1',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3048','SAI RAMA DAIRY_ADBM1',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3049','MARUTHI STORES_ZP',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR305','SELVAM PROOVISION',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3050','THIRUMURUGAN STORE_ZP',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3051','SREE ANANDHA STORES(SLR)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3052','S.K.GENERAL STORE(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3053','SRI VENKATESHWARA BAKERY & SWEETS(MDM)',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3054','SOUNDRA PANDIAN STORES(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3055','AKASH STORES(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3056','S. S. STORE_PVLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3057','JANANI STORE_PLVM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3058','PERIYANDAVAR STORE_OPLM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3059','SHIVANI ICE CREAM PROVISION STORE_VEL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR306','VENKADESWARA PROVISION(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3060','AMMAN STORE_VEL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3061','BALU STORE_CHRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3062','NELLAI KANI STORE_MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3063','MUNISWARA PALPORUL ANGADI_OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3064','C. S. STOVE_NAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3065','DEEN NATTU MARUNTHU KADAI_ADBM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3066','AATHI HARSHINI STORE_VEL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3067','THIRUMURUGAN STORE_PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3068','SAKTHI STORE_CHITLAPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3069','LAXMI STORE_RAJAKILPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR307','A.V.R.PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3070','AROKIYA MADHA STORE_RAJAKILPAKKAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3071','BALAJI NATTU MARUNTHU KADAI_KAMARAJAPURAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3072','SATHYA STORE_KAMARAJAPURAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3073','BALAJI STORE_CHRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3074','ANANTHA STORE_SELAIYUR',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3075','MARUTHI PAN CENTER_SELAIYUR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3076','RAJAN MALIGAI_SELAIYUR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3078','FIRBAA TEA STALL_SELAIYUR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3079','HARI PRIYA STORE_PALAVANTHANGAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR308','KANNAN STORE(E.TBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3080','DHANJAI SARAVANA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR30801','AMMAN TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3081','JENITHA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3082','KANISHKA SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3083','SARAVANA NEWS MART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3084','MAHA RAJA SEEVAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3085','HARI KRISHNA NAATU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3086','GOPAL NAATU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3087','VEMBULI AMMAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3088','ROJA FANCY _STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3089','BALAMURUGAN STORE(POZ)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR309','SIVA LINGAM STORE(E.TBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3090','ATHITHYA SUPER STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3091','SEELA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3092','MURUGAN STORE-2',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3093','AADHISIVAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3094','K.B.NATTU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3095','DIVYA SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3096','RASOOL TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3097','A.M.STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3098','VINAYAGA STORE-ADM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3099','RAMANATHAN STORE.',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR31','SRI BALAJI MEDICAL-AKP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR310','LAKSHMI IYYANGAR BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR311','MURUGAN STORE(ETBM) 1',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3119','SRI SAI STORES (MGR)',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR312','MUTHU LAKSHMI STORE-CHE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR313','SELVARAJ STORE(ETBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR314','AMBAL STORE(GOW)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR315','SARAVANA NEW STORE(GOW)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR316','PUSHPAM STORES (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR317','LAKSHMI STORES - GOW',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR318','ARCHANA SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR319','BASKARAN STORE (GOW)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR32','GANESH MEDICAL-AKP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR320','MAHALAKSHMI  PROVISION STORE(GOW)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR321','ABI STORE (GOW)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR322','ANBU STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR323','ANNAI STORE - VJN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR324','DEVI STORE(GOW)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR325','EZHIL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR326','KAMATCHI STORE(VEN)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR327','KARTHIK STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR328','NIRMAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3287','VIJAYA STORE-9976594594',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR329','SAKTHIVEL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR33','JJ STORE-ANAKAPUTHUR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR330','SARADHA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR331','SRI BALAJI STORES {VGVSL}',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR332','SAKTHI PROVISIONAL STORE-VGSL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR333','AMBAL THANGAM STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR334','SRI KAMATCHI PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR335','SRI SELVA VINAYAGAR STORES (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR336','GURUSWAMAY (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR337','IYYANGAR PROVISION(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR338','KAMAKSHI SRI STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR339','SRI LAKSHMI STORES (HAS)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR34','5 STAR MAGALIR MALIGAI KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR340','MAHARAJA STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR341','OM SAKTHI STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR342','SRK PROVISION STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR343','MERCY PROVISION STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR344','SRINIVASA STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR345','SUDHA STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR346','VAIRAMANI STORE ( HPM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR347','R.R.STORE ( HAS )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR348','ANANDHA STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR349','BALAMURUGAN STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR35','RIHA DAILY NEEDS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR350','GANESH STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3500','LAKSHMI RICE STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR351','JANAKI STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR352','JENIFER STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR353','THILLAI STORE - HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR354','LAKSHIMI STORE (HAS)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR355','MADHESH TRADERS(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR356','MAHA LAKSHMI STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR3562','LEO BAGS',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR357','MURUGAN STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR358','MUTHU KRISHNA STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR359','RISVAN STORE (HAS)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR36','RAJASEKAR BUNK KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR360','S.R.PANDIAN STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR361','SEDHU RAMAN STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR362','T.MURUGAN STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR363','VAIRAM STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR364','RAJAPANDI STORES(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR365','B.RAJA STORES (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR366','SRI SAI SAKTHI DAY TO DAY SUPER MARKET-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR367','SRI SAI SANKARA STATIONARY&GENERAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR368','MUTHARAMMAN STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR369','SAKTHIVEL STORE(HPM)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR37','SELVA VINAYAGAM STORE(AKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR370','KAMAKSHI AMMAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR371','ISHYA PURPLE N BLUE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR372','MAGESH DEPT. STORE  (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR373','PATHA MUTHU STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR374','PRIYA STORE ( HPM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR375','D.SAMUVEL MALIGAI(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR376','SUBRAMANI STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR377','MADHAJI GENERAL STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR378','LUCKY GROCERIES - HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR379','KANI COOL BAR (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR38','BALU TRADERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR380','LAKSHMI RICE STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR381','ANNAI PARASAKTHI STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR382','THIRUMALAI HOT PUFFS & SWEETS-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR383','SRI MURUGAN COOL BAR-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR384','SAMPATH RICE MANDI-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR385','ARUL SAKHAYA STORE-1- MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR386','SHANKAR STORE (KRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR387','NELLAI NEW STORE(E.TBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR388','A.DOSS STORE (KRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR389','AKBAR STORE ( KRM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR39','SANKAR STORE (AKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR390','K.P.S.MOOSA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR391','AAKASH STORE - KRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR392','KANNAN STORE-MDM2',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR393','SIVA SAKTHI STORE - KRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR394','BALAMURUGAN STORE KRM (SRI GAHESH PROV)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR395','ASCI ELECTRICALS & PLUMBING (KRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR396','SREE SAI SHOPPING MART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR397','VENKATESHWARA STORE(RJK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR398','SARASWATHI STORE - KRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR399','NEW MERCY SUPER MKT(KRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4','RAM DEV PROVISION STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR40','LATHA STORE (AKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR400','KS GENERAL STORE(KRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4000','sri mangala maruthi pooja store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4001','MALLIIGA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4002','SRI MUTHURAMMAM PALAMUTHIR SOLAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4003','START UP CAFE TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4004','RAMESH TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4005','SELVI STORE (POZ)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4006','BAGLE BAZAAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4008','KUMAR SUPER MARKET.',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4009','MUTHARAMMAN STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR401','LAKSHMI NEW STORE(MDM)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4011','S.V.S STORE(MBK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4012','STAR PROVISION STORE_PM',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR402','ANANDHAVALLI STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR403','JOHNSON STORE - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR404','IBRAHIM STORES - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR405','M.K. MURUGAN STORE { MDM }',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR406','SRI MARIYAMMAN STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR407','UDAYAM MAGALIR SUYAUDAVI KUZHU(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR408','PONNU STORE - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR409','JACKIN STORE - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR41','DURGA STORE -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR410','THIRUMAL STORE-MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR411','KAMACHI AMMAN STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR412','KANI STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR413','LINGAM STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR414','MARUTHI SHOP(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR415','MUTHU STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR416','MUTHU STORE(MAD)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR417','NATARAJAN STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR418','RAJALAKSHIMI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR419','SOWBAKYYA MALIGAI(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR42','LINGAM STORE -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR420','YOGAVATHI STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR421','PARVATHI STORE (MAD)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR422','SARADHA STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR423','JESY STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR424','PADMA STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR425','SELVA LAKSHMI STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR426','ANBU MALIGAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR427','JAYAM XEROX &  STATIONERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR428','AYYANAR STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR429','DURAI STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR43','LINGAM STORE (AKP) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR430','GANAPATHI STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR431','SRI GANAPATHY SWEETS&BAKERY (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR432','KANNI SRI STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR433','KRITHIKA MALIGAI(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR434','MURUGAN STORE ( MDM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR435','PARVATHI NEW STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR436','PAVITHRA STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR437','SAMY STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR438','SRI MUTHARAMMAN STORE MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR439','SHANKAR STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR44','SHANMUGA STORE(AKP) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR440','SHANMUGA PRIYA STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR441','VIJAYALAKSHMI STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR442','CHANDRA VEGETABLE FRUITS & ICE CREAM SHOP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR443','LAKSHMI STORES - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR444','MANI STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR445','ARUL SAGAYA STORES 2 (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR446','MOORTHY STORES (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR447','ZINNA GENERAL STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR448','LATHA SRI STORE ( VNGAI VSL )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR449','LAXMI HOT PUPS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR45','PANDIYA HOME NEEDS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR450','SARAVANA SRI STORE ( AGRM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR451','AMMAN NEW STORE (AGRM)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR452','ANANTHA VINAYAGAR STORE (AGAM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4526','kannan store CHROMPET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR453','BALA STORE ( AGRM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR454','BASKER SUPER MARKET AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4545','SR LAKSHMI COOL BAR-9566299505',1,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4546','JAYAM KEERTHI MALIGAI-9940540330',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4547','ANANDHA STORE-CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4548','ALEENA STORE-9840409139',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4549','JAANAKI MEDICALS-9840033267',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR455','GAUTHAM STORE - SRI MUTHARAMMAN STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR456','DEVI SRI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR457','JAYA MEENA STORE ( AGRM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR458','JAYALAKSHMI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR4582','sri ganapathy sweet & bakery',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR459','MURUGAN SRI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR46','G.V.S.THIRUPATHI STORE(ANK) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR460','MUTHU NEW STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR461','PON CHITRA STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR462','PUSHPAM STORE ( AGRM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR463','SONACKA STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR464','SRINIVASAN STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR465','SURESH STORE ( AGRM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR466','VETRI VEL STORE ( AGRM )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR467','JVS SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR468','SUYAMBULINGAM STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR469','SIVANI STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR47','HOT PUFFS & CHIPS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR470','BANU STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR471','VETRIVELAN STORE - MDM / JABA SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR472','PRIYA FANCY STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR473','BHAWANI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR474','SRI LAKSHMI STORES (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR475','POORVIKA STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR476','JAGADAMBA PROVISION(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR477','JAYAM STORE (MDK)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR478','SRI KRISHNA PROVISION - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR479','CHITRA STORE - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR48','SHARLIN STORE-AKP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR480','SAI SIVASAKTHI STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR481','CITY STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR482','S.DHANGARAJ STOTE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR483','KAMATCHI STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR484','SRI BALAJI STORES.',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR485','SRI KUMARAN STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR486','SRI VARSHINI STORES VEG & FRUIT MART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR487','JEYA STORE (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR488','LAKSHMI HOT PUFFS (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR489','ALFA TEA STALL-NKG',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR49','SHREE VELAVAN STORE-KRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR490','SAKTHI STORE(NGK) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR491','RAMANATHAN STORE(NKG) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR492','PARVATHI STORE(NGK) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR493','SUBUHAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR494','ANITHA STORE(NKG) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR495','APPU STORE(NKG) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR496','CHANDRAMOHAN .K(NKG) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR497','SELVAM STORE(NKN) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR498','KAUSAR GROCERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR499','SRI MAHI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR5','GANAPATHY STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR50','SATHYA STORE(AKP) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR500','GEETHA STORE -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR501','RAJAPANDIAN STORE -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR502','SRI VIGNESHWARA RICE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR503','LONDON MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR504','MURUGAN MEDICAL-O.PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR505','ALAMU MEDICALS-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR506','SANJANA MEDICAL & GENERAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR507','DHANALAKSHMI MEDICAL-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR508','PANDIAN STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR509','A.N.S.STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR51','RAJA STORE(AKP) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR510','A.R.STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR511','HARI MINERAL WATER SUPPLY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR512','SANTHOSH STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR513','CHELSEA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR514','THE KRISH NETWORKS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR515','SRI SAI KRISHNA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR516','AMUL STORE(O.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR517','CALD WELL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR518','KARTHIKA STORE(O.PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR519','MAHALAKSHMI PROVISION(OPLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR52','NEW MARUTHI BAKERY.',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR520','OM PROVISION (O.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR521','R.R.STORE(O.PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR522','SARASWATHI NEW STORE (O.PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR523','SUNDARLINGAM STORE(O.PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR524','SUYAMBU LINGAM STORE (O.PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR525','SRI MADHAJI PROVISION STORE(O.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR526','JAGATHEESH BROTHER MALIGAI(OPLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR527','SRI KAMACHIAMMAN STORE(OPLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR528','M.S STORE(OPLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR529','AKASH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR53','NEW RAJAMANI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR530','GEETHANJALI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR531','ANGEL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR532','SRI BALAJI STORE-O.PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR533','MUTHARAA STORE-O.PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR534','BUVANESHWARI STORE-2-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR535','VELU STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR536','CHOCOLATE BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR537','AAMARAVATHI STORE(O.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR538','ANNAI NEW STORE (O.PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR539','ARUL REVATHI STORE(OPLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR54','SOUMIYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR540','AYYANAR STORE(OPLM)3 -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR541','BOOPATHY STORE -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR542','CHINNA DURAI STORES (O.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR543','JAYAMURUGAN(O.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR544','RAMA STORE(OPLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR545','S.M.MUTHU STORE(O.PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR546','SAMADURI STORE(O.PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR5467','SAI MALIGAI-8939214189',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR5468','KRISHNA TEA STALL-9840788054',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR5469','HARINI STORE-9840501815',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR547','SUNDARA PANDAIYAN STORE(O.PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR5470','NEW LINGAM STORE-9444126605',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR548','NIRMALA STORE(OPLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR549','RAJA STORE1(OPLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR55','SARKARAVARTHI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR550','S.SARANYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR551','JAYANTHI STORE-O.PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR552','SRI VENKATESWARA SWEETS & BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR553','PONVINAYAG STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR554','SM MEDICALS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR555','ARCHANA MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR556','SRI VENKATESWARA SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR557','ARUMUGAM STORE-OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR558','BUVANESWARI STORE 2-S.R',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR559','ABBAS STORE (MA STATIONARY)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR56','SENTAMIL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR560','SREE MATHAJI PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR561','KRISHNA MEDICALS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR562','J.P.STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR563','SIMSUN STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR5631','Jayam seeval store-AMD',2,15
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR564','S.S.S ANNAPOORANI CATERING-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR565','SARAVANAN STORE..',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR566','MOTTAIAL SWAMY MALIGAI STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR567','SRI GURU RAGAVENDRA GEN STORE(PAL) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR568','AATHIYAPPAN STORE(PAL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR569','THAI SNACK CENTRE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR57','DAY 2 DAY SMART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR570','LAKSHMI STORE(PAL) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR571','O.NABI STORE -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR572','CHUKRA PHARMACY-PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR573','LAKSHMI HOTEL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR574','SRI LAKSHMI ST',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR575','THANGAPPAN COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR576','A.S.COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR577','ARAMANA TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR578','DHANSIKA COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR579','RALLIYA FANCY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR58','SRI MURUGAN SUPERMARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR580','MEENATCHI STORE (PVM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR581','K.M.STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR582','EM.EL STORE (PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR583','KAVIYA TRADERS OPLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR584','VIJAY STORES -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR585','JAYAM ENTERPRISES (PVM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR586','A.G.PANDIAN STORE (PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR587','MOOKAMBIGAI STORE (PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR588','MUTHU GENERAL STORE(PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR589','PALLAVARAM PROVISIONAL STORE(PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR59','SRI PROVISION & RICE STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR590','PR PANDIAN STORE(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR591','SELVAJOTHI PROVISION STORES(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR592','SENTHIL STORE (PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR593','AFRIM STORE-OPP COMPANY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR594','APJATH STORE (PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR595','K.M.A.R STORE (PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR596','SARAVANKUMAR STORE (PVM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR597','NEW RAHMATH STORE(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR598','KUMAR MILK & COOLDRINKS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR599','DOWLAD STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR6','MUTHUSELVAI STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR60','NEW AMBIKA PROVISION',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR600','R.K HOT PUFFS BAKERY & SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR601','SUMITHRA STORE OPLM -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR602','SUYAMBU STORE(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR603','C.SAKTHI COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR604','SM TRADERS-PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR605','ARASAN STORE (PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR606','SRI ANGALAMMAN STORE -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR607','AYYANAR SRI SUPERMARKE (PLM) -A',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR608','JAYARAJ MALIGAI -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR609','A.S.S.PROVISION STORE(PLM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR61','RAJAMANI STORE (AKP) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR610','MURUGAN STORE(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR611','ABI STORE-PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR612','MUTHUMALAIAMMAN STORE(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR613','MANI SWEETS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR614','PADMAVATHY PROVISION -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR615','RAJI STORE(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR616','IMMANUVEL STORE PML -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR617','MADAN STORE(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR618','A.S. STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR619','SURYA COOLBAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR62','A.M.SELVAM STORE(AKP) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR620','SARAVANAKUMAR STORE (PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR621','SANGLI STORE(PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR622','SUBHA STOER(PLM) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR623','S.R.A.STORE(PLM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR624','SRINIVASA PERUMAL SEEVAL NADDU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR625','T.N.A STORE(PLM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR626','HANEEF STORE(PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR627','JAFAR SEEVAL STORE(PLM) -C',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR628','LIFE PLUS MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR629','GOOD HEALTH PHARMACY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR63','BRINDHA STORE(AKP) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR630','GIRI MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR631','GOPAL SEEVAL(PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR632','SRINIVASA SEEVAL(PLM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR633','HARIKRISHNA NAATU AMARNDHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR634','ARASAN PROVISION (PLM) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR635','JAMUNA SEEVAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR636','N.V.R.ARISI MANDY -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR637','WELCOME STORE (NAGALKENI)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR638','MAGANA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR639','A.N.S STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR64','JACOB SRI STORE(AKP) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR640','T.R.PANDIYAN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR641','RAMYA STORE PALLAVARAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR642','RAGAMATH STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR643','SUSILA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR644','RAASI HERBAL STORE - PAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR645','SRI AYYANARA STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR646','AGESTIN STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR647','JAYAM PROVISION-(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR648','SRI VINAYAGA MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR649','MALAR MEDICAL-PML',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR65','JAYA NEW STORE (AKP) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR650','R.JOSEPH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR651','RAVIKUMAR STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR652','KALAIMAGAL COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR653','MURUGAN STORE -PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR654','AMUTHA TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR655','REVATHI STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR656','M.B.S.STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR657','S.S.STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR658','S.MARISELVI STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR659','RAJAGOPAL TEA STALL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR66','KANNIAMMAN STORE -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR660','SUSI FANCY(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR661','HYPER SHOPEE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR662','HARI VEGETABLE STORE(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR663','SIVAMURUGAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR664','WELCOME STORE(P ML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR665','ASHOKA STORE (PML) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR666','JAYANTHI STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR667','JOTHI STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR668','M.M.STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR669','MANI STORE -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR67','L.M.S.PROVISION STORE -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR670','PRIYA STORE -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR671','SANGEETHA STORE(PML) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR672','SELVA VINAYAGAR STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR673','VENUS MALIGAI(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR674','PRIYA FANCY PML-C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR675','JANARTHANAN TELECOM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR676','DEEPA COOL BAR(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR677','MURUGAN STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR678','HANIFA STORE (PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR679','SEKAR STORE (PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR68','MURUGAN STORE(AKP) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR680','SRI MALAI AMMAN STOREI (PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR681','ARUNA STORE (PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR682','BAVANI STORE -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR683','JAWAHAR STORE (PML) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR684','KANITHA STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR685','MURUGAN SRI STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR686','PERIYA ANDAVAR STORE (PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR687','RAJA STORE (PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR688','MUTHARAMMAN STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR689','PRABU STORE(TMR) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR69','RAJESWARI STORE (AKP) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR690','R.S.STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR691','GREEN STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR692','GANESAN STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR693','PERIYA SWAMY STORE(PML) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR694','RAJ STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR695','SAKTHI STORES(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR696','SM.STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR697','SRI DEVI STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR698','JAYALAKSHMI STORE-PML-A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR699','MURUGAN STORE -PML-A SRI VINAYAGA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR7','SRI SAI SUSEELA',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR70','TAMIL STORE (AKP) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR700','ANANTHI STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR701','BALAN STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR702','EASWARI STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR703','ARUNA STORE2(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR704','THANGAM STORE-PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR705','THIRU KALYANA MADHA PROV-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR706','ANGALAMMAN STORES(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR707','B.S.BANU STORE(PML) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR708','CHITHRA STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR709','SIVASAKTHI RICE MUNDY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR71','SRI DEVI STORE (AKP) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR710','SAKTHI STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR711','JOTHI STORE (PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR712','SRI DEVI STORE - PLM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR713','RAJALAKSHMI NEWSMART (PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR714','KANNAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR715','HARIPRASANTH COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR716','ESSAKI AMMAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR717','SELVA KUMAR STORE( PVM) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR718','SENTHIL STORE -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR719','MEGALA STORE (PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR72','NELLAI ANBU STORE(AKP) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR720','SENTHIL STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR721','IMANUEL BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR722','JAYA STOR-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR723','SIVA SAKTHIVEL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR724','ANBU STORE (PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR725','ARRAHMAN -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR726','MUMTAJ STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR727','PONNI STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR728','HIDUJA STORE(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR729','ARUN HOME NEEDS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR73','SRI JAIN STORE(AKP) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR730','NEW GEETHA STORE(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR731','SELVAM PROVISION STORE (PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR732','MAHENDHIRAN STORE(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR733','RTV STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR734','S.R.A NAATU MARUNTHU KADAI-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR735','A.S.B SEEVAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR736','S.V STORE(PML) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR737','SRI MUTHURAMMAN STORE(PML) -DN',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR738','RATHINAM STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR739','MUTHU MALAI MALIGAI (PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR74','MURUGAN STORE (AKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR740','VSM STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR741','NANDHIESHWARA MEDICAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR742','DELIGHT FRESH',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR743','SARAVANA NAATU MARUNDHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR744','ROJA STORE(PML)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR745','KOWSALYA PROVISION STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR746','R.K.SHOP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR747','DEV STORE-PML',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR748','PANDIAN STORE(PML) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR749','THANGAM STORE PML -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR75','PANDIAN STORE-AKP',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR750','SIVARAMAN MALIGAI(PML) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR751','SRI SAKTHI SANDYAMMAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR752','NEW MURUGAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR753','VEERAPANDIAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR754','SIVA VISHNU STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR755','MUTARAMMAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR756','ASARAF STORES PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR757','SARAVANA STORES PAMMAL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR758','THAMILCHELVAN STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR759','T.K.R.S GENERAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR76','BISMILLAH PROV. ST..',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR760','SRI VINAYAGA ST-POL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR761','KUMAR SRI STORE(POL) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR762','MARIE STORE (POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR763','PERIYA ANDAVAR STORE (POL) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR764','ANGALAMMAN STORE (POL) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR765','ANNAMALAI PROVISION(POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR766','BALAJI STORE(POZ) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR767','JENIFER STORE(POZ)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR768','KRISHNA STORE(POZ) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR769','KUMARAN STORE (POL) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR77','KUMUDHAM STORE (CHR) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR770','LAKSHMI SRI AGENCIES (POL) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR771','MURUGAN STORE(POL) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR7710','A.K.AGENCY',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR7711','DHEEN NATTUMARUNTHU KADAI',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR7712','SHREE THIRUTHANI SUBRAMANIYA SWAMY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR772','OM SARAVANA PROVISION (POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR773','PARAMASAKTHI STORE (POZH) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR774','RAJAM STORE(POZ) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR775','SELVAM STORE (POZ) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR776','SOUNDARAPANDIAN STORE(POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR777','THANGA PANDIAN STORE (POZ) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR778','SARASWATHI STORE(POL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR779','TAMILARASI STORE {POL} -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR78','SRI MUTHARAMMAN STORE -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR780','THANGAPPAN STORE {POL} -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR781','JASMINE STORE(POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR782','LINGAM STORE-POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR783','CHANDRA STORE (POL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR784','KUMARAN STORE (POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR785','S.P.R STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR786','JOTHI COOL BAR(POL) -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR787','RENUKA ST-POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR788','MANARAJA SRI STORE(POZ) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR789','MAHARAJA STORE.POL -A',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR79','MESYA STORE (AKP) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR790','NIRMALA STORE(POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR791','RAGAVAN SRI STORE(PML) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR792','LAKSHMI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR793','S.K. STORE(POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR794','SRI MURUGAN STORE(POL) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR795','SRI KANIS STORE-POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR796','AYYANNAR STORE(POZ) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR797','GANGA STORE(POZ) -C',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR798','THANGAM STORE(POL) -SC',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR799','SRI KAMATCHI STORE (POZH) -B',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR8','BHAVANI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR80','SRIDHAR MEDICALS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR800','ANANDHI STORE POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR801','SAM STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR802','MA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR803','AKSHAYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR804','KAMATCHI AMMAN STORE-POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR805','LAKSHMI STORE-KAULBAZAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR806','NESAM STORES-POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR807','THIRUMURUGAN STORE- POZ',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR808','ROJA FANCY STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR809','MALLIKA SWEETS & BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR81','SUGANYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR810','EBENEZER STORE(POL) -SC',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR811','SRI MAHALAKSHMI STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR812','SANKAR FAMILY MART (RKM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR813','SELLAMAH FOOD CITY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR814','RATHANA STORE(RKM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR815','CHITRA DEVI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR816','LEKHA MULTI STORE (RKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR817','V.P.R DEPARTMENT STORE(KRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR818','UDDHAV STORE (RKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR819','RAVI PROVISION (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR82','ANITHA STORE(AKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR820','T.S.P.& CO.(SAN)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR821','SANTHOSHI ANGADI (SATPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR822','SELVAM STORE(PARK ST)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR823','SRI SUYAMBILINGAM VEG SHOP (VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR824','RATHNA KERLA HOT CHIPS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR825','DHANALAKSHMI STORE (SPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR826','MUTHIYA PROVISION(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR827','SRI MURUGAN STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR828','MURUGAN STORE ( SLR )',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR829','AKASH STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR83','GOKULAM STORE (PLM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR830','BALAJI COOL BAR (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR831','DAYANA DEP.STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR832','SELVAM STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR833','THANJAI KUMAR (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR834','M.P.STORE - SEL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR835','SRI PONNAMBALA NADHAR MALIGAI (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR836','ADHITHIYA STORE-E.TBM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR837','SRI GANESH STORES (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR838','AYYANAR STORE - MDM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR839','RUBAN STORE(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR84','PANDI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR840','VANITHA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR841','YUGE MOTHI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR842','GOLDEN PROVISION STORE(SEL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR843','GANGA SRI PROVISION (E.TBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR844','BASKAR COOL BAR (SEL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR845','BALA SRI VINAYAGAR STORE(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR846','SRI GANESH PROVISION STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR847','S.R. BROTHERS  -  JAYATHI',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR848','NILA STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR849','RAJESWARI STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR85','BUVANESH STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR850','SRI KALATTHI GENRAL STORE(SEL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR851','P.A.SONS (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR852','P.A.VIJAYAN RICE MANDY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR853','M.H.STORE(SLR)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR854','MUTHUKUMARAN STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR855','S.M.STORE (SLR)',2,10
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR856','VENKATHESWARA SRI SWEETS&BAKERY(SEL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR857','R.M. MALIGAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR858','DEEPAN STORE (OPP. SEKAR STORE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR859','THANGAM SUPER MARKET (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR86','SRI MAHA RAJA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR860','SRI BALAJI STORES (RJP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR861','RAJA COOL BAR (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR862','VIVEKANANTHA STORE(SEL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR863','ANBU STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR864','JAYA LAKSHMI(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR865','MUTHU PARVATHI STORE(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR866','SAKTHI STORE SEL',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR867','SHANKER STORES(SLR) (V)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR868','J J SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR869','ARPUTHARAJ STORE(AGR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR87','AJANTHA COOL BAR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR870','JAYARAM SWEETS & BAKERY',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR871','VAIBHAVE SHOPPE SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR872','SENBHAGAM STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR873','JJ TRADERS (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR874','LAKSHMI HOT PUFFS (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR875','SHREE PACHIYAMMAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR876','JK TRADERS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR877','THANJAI STORE (CAMP RD)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR878','JAISON STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR879','SRI ANANDHA STORE - SLR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR88','ANNAMALAI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR880','ANANTHI NEWS MART (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR881','SAI PRASADH MALIGAI (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR882','GANESH STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR883','GANESAN STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR884','MASILAMANI STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR885','KANJANA STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR886','KARPAGA VINAYAGAR  STRORE-SLR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR887','SAINI STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR888','J.S FANCY & STATIONERY (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR889','V.A.M STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR89','JALAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR890','ABIRAMI STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR891','J.K STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR892','HILIGHT CHOOSE & SNACKS (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR893','UDHAYASINGH STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR894','KUBER STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR895','SRI GANAPATHY XEROX',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR896','SRI PERUMAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR897','SK VINAYAGA STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR898','PADHA MUTHU STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR899','ELAKIYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR9','VENKATESWARA SWEETS (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR90','SERMAN STORE (AKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR900','SRI MUTHARAMMAN PALAMUDHIR SOLAI(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR901','EMILY STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR902','SEKAR STORE {MDM}',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR903','MUTHU LAKSHMI STORE(MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR904','NEW ROYAL BEKERY (E.TBM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR905','ANNAI ANGADI (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR906','AMMAN STORE (SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR907','SRI GANAPATHY SWEETS&BAKERY (MDM)-2',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR908','SRI GANAPATHY SWEETS & BAKERY (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR909','ANITHA SUPER MARKET (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR91','GOKUL PROVISIONS STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR910','ANNA LAKSHMI RICE SHOP(SEM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR911','MADHAVA GENRAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR912','ZARINA ICE CREAM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR913','LAKSHMI  HOT PUFFS - 2',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR914','RANI AMMAL PROVISION &VEG',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR915','SRI SELVAM STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR916','BHARATHA LAKSHMI SHOPPING',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR917','PRABHA STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR918','VVS STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR919','SAI RAGAVI MINI SUPER MARKET',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR92','KASTHURI PROVISION(RKM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR920','M.R.V. STORES (SAN)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR921','SWASTIK STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR922','SATHYA STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR923','SHANMUGA STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR924','JAYALAKSHI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR925','NEW VINAYAGA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR926','SRI MARIAMMAN STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR927','PERUMAL PAZHAMUTHIR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR928','SHREE SELVA VINAYAGA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR929','JAIN BEAUTY CENTRE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR93','SELVA KANNAN STORE(RKP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR930','SAKTHI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR931','GANESAN STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR932','SRI AMMAN STORE (KSP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR933','NEW VADIVEL (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR934','HARI SUDAN(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR935','SRI SELVA VINAYAGA STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR936','SHAKTHI MALIGAI (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR937','PRIYA STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR938','OM SAKTHI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR939','NEW VEERALAKSHMI STORE AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR94','RAGAVENDRA GENERAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR940','K.S.STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR941','YUVARANI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR942','SHRI MURUGAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR943','YOGESWARI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR944','RABHATHU STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR945','SRI SELVA VINAYAGA STORE-AGRM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR946','ANNAI VELANKANI STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR947','MURUGESAN STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR948','ABITHA STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR949','A.S STORE-(VGSL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR95','THOGAI NATHEN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR950','PATHANJALI ORGANIC/IAF RD',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR951','RAASI NEWS MART',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR952','JUICE CORNER',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR953','SELVA DURAI STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR954','GANTHA LAKSHMI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR955','SIVA STORE TBM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR956','KUBER STORE(SLR)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR957','VEERA LAKSHMI STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR958','AMMAN STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR959','NEW VADIVELU STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR96','NELLAI KALYANI STORE(RJP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR960','S.A.SUPER MARKET(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR961','HARI SUDHAN STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR962','YOSHVA STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR963','JK STORE(AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR964','CHRISTOPER STORE (AGRM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR965','ANTHONY FANCY (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR966','SIVA SANKARAN STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR967','SARAVANA BAKERY(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR968','SATHISH STORE(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR969','THIYAGU STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR97','GANAPATHI SRI STORE(RJL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR970','KAMACHI AMMAN STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR971','SARAVANA FRESH JUICE CORNER(HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR972','JUICE WORLD-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR973','BHAKIYA LAKSHMI TRADERS(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR974','SRI SAI BABA GENERAL STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR975','KANTHALAKSHMI COOL BAR(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR976','M.H.S.STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR977','LONDON BAKERY(HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR978','ANNAI PROVISION (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR979','SRI MURUGAN STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR98','AROKIYA ANNAI STORE(CHE)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR980','S.L.J BAKERY (GOW)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR981','SARATHA COOL BAR (VGVL)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR982','KAVITHA STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR983','LAKSHMI STORE (CPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR984','DIVYA NADAR STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR985','THANGAM STORE - W.TBM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR986','ARUNACHALA STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR987','DEVI STORE-HPM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR988','SAMY STORE (CPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR989','THILAGAM STORE - W.TBM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR99','BISMILLA STORE(RJP)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR990','P.S PANDIAN STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR991','PONRAJ STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR992','THILLAI STORE (MDM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR993','PAVITHRA MALIGAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR994','SANTHI STORE',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR995','NEW RAJA STORE (HPM)',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR996','DIVYA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR997','ALLTA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR998','SAGAYA MADHA STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCGR999','CAMP SNACKS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCINS1','ELLIOT FOOD',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCINS2','SAKTHI&CO',2,14
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS1','GROFRESSH SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS10','NEW SARAVANA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS100','LINGAM SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS1000','WELCOME HOTEL',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS1005','VILLAGE MART',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS101','GRACE WORLD SUPER MARKET(CHEM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS1010','GANESH CINIMAS',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS102','ANANDHI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS103','PICK N PACK DEPARTMENTAL STORES(AGRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS104','ALAGAR SUPER MARKET (SLR)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS105','LARDER MART(SLR)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS106','AMMA SUPERMARKET (HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS107','RAJESWARI SUPER MARKET (KRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS108','CHENNAI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS109','SEEDS NATURAL MARKET (HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS11','MANOJH SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS110','RAINBOW SUPER MARKET(SPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS111','ARADHANA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS112','TOWN BAZAAR VGSL',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS113','LAKSHMI PRIYA STORES (SLR)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS114','MAHARAJA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS115','NILGIRIS (FINE MART)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS116','AK SUPER MARKET (MDM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS117','V.S HYBER MART.',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS118','S&S SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS119','7/7 SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS12','VIGNESH SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS120','JAI SUPER MARKET.',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS121','LAKSHMI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS122','J&G MART',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS123','SARAVANA SUPERMARKET -9841463947',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS124','SHANTHI SUPER MARKET -VELACHERY -9444280088',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS125','JOY SUPER MARKET(GOW)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS1258','SRI AMBIKA SUPER MARKET (CHR)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS126','LAXMI SUPERMARKET-ZPLM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS127','SRI MURUGAN SUPERMARKET-AKP',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS128','DAY 2 DAY SMART -PAL',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS129','HARSHINI ENTERPRISES-ZPLM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS13','AMUTHU SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS130','VIVASAAYAM STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS131','US MART-TML',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS132','RAJENDRAN PROVISION STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS133','INIIAS SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS134','SHREE KUMARAN DEP.STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS135','KUMAR SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS136','VIGNESHWARAS DEPARTMENTAL STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS14','LAKSHMI SUPER MARKET(CHE)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS142','PRIME MART SUPER MARKET(UNITED BLOOM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS15','AL-GREEN SUPERMART(CHE)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS154','JOY SUPER MARKET NEW(GOW)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS155','UNIK ASSOCIATES (NILGGIRIS)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS16','GAYATHRI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS163','SHRI AYYANAR SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS17','VENKATESHWARA SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS18','SRI ANDAL SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS189','DIVINE MART',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS19','SIVAGAMY SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS2','SRI NAGAAS SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS20','ANANDHI MINI DEPARTMENT',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS200','JAYAS SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS201','JAYAS SUPER MARKET(EAST TBM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS202','JEYAMANGALAM SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS203','HI-FI FOOTWEAR & SHOPPING MALL',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS204','J.P RAJA STORE (CAMP)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS205','SHREE RAJESHWARI STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS206','LALITHA SUPER MARKET (SAN)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS207','VV MART- VEL',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS208','MUTHAIYA PROVISIONS STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS21','AMBIKA RETAIL PVT. LTD',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS210','MURUGAN STORES SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS22','POOMANI SUPERMARKET.',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS221','S.K.R.SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS226','JKM ENTERPRISES PVT LTD',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS23','UNIVERSAL SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS24','RAMMIYAM SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS25','LU & LU SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS250','SEKAR STORE(MDM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS251','MUTHU STORE(CHROM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS252','ANITHA SUPERMARKET -ADBM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS26','SHABHARI SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS27','HYATT SUPER MARKET (CPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS28','GANESH DEPARTMENTAL STORE-CHR',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS29','KURINJI BAZAAR',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS3','GAYATHRI SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS30','MAXX MART SUPER SHOPPEE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS300','SRI MAHALAKSHMI SUPER MARKET(W.TBM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS301','BALA SAI NARAYANA AGENCIES BPCL DEALER_CIG',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS302','LAXMI SUPERMARKET-CIG',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS303','LAKSHMI STORE MALIGAI',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS304','SEKAR STORE MAM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS31','ANADHA SUPER MARKET -A',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS32','SMART FRESH SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS33','NEW CORNER DEPT STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS34','ASHWIN SUPER MARKET (CHR) -A',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS341','NEW SARAVANA STORE-BRIN',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS35','V.S.P. SUPER MARKET(CHR) -A',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS36','CHROMEFRESH SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS37','SHRI SARVESHWARA SUPER STORE',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS38','SHRISHA ENTERPRISES',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS39','AMMA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS4','S.P SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS40','K2M SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS41','NEW JAYAM DEPARTMENTAL STORES(PICK&PACK)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS42','KK SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS43','PICK N PACK DEPARTMENTAL STORES',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS44','THANGAM SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS45','SRI VENKATESHWARA SUPER MARKET(GOW)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS46','MAKARY GRENNS&SPICES',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS47','MADRAS SUPERMARKET - 9962222152',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS48','SRI JAYAMANGALAM SHOP SAVE-9941187557',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS49','MAGESH HYPER MARKET (HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS5','SRI VENKATESHWARA SUPER MARKET(AGRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS50','NIRBA RETAIL(HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS51','V S R SUPER MARKET(HPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS52','BALA SAI NARAYANA AGENCIES BPCL DEALER',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS53','GREENS SUPER MARKET/HPM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS54','SIDDIQ SUPER MARKET (KRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS55','NELLAI SUPER MARKET (KRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS56','AISHWARYA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS57','BHARANI SUPER MARKET(AGR)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS58','JAYAM SUPER MARKET ( MDM )',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS59','CASH & CARRY SUPER MARKET(MBM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS6','SIVA SAKTHI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS60','SRI SHANMUGAVEL SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS61','AGS SUPER MARKET {MDM}',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS62','THERISHWAR SUPER MARKET(MDM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS63','OLIVE MART (MDM).',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS64','SIDDIK SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS65','GARDEN FRESH (MDM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS66','J.V.S.SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS67','MAHADEV SUPER MARKET (MDM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS68','SRI SARAVANA STORE- RKM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS69','NEW PONNU STORES (MDM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS7','MORIHA MEGA MART (AGRM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS70','SRI VENGATESHWARA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS71','NANGANALLUR SRI ANJANEYAR SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS72','BALAJI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS73','EASY SUPERMARKETS',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS74','V V MART',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS75','BISMI MINI MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS76','ANNAI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS77','SRI JAYANTI NATHA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS78','MATHURA SUPARMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS79','V MART',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS8','DHANALAKSHMI SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS80','SHREE KRISHNA SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS81','SRI PERUMAL SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS82','SRI PERUMAL SUPERMARKET-ZPLM2',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS83','DAY TO DAY NEEDS SUPPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS84','FAMILY SUPERMARKET-PML',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS85','APOORVA SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS86','NATIONAL SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS87','DAY 2 DAY NEEDS',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS88','SAI BALA FRESH SUPERMARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS89','SS SUPERMARKET-PML',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS9','POORVIKA SUPER MARKER....',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS90','R.K ENTERPRISES',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS91','JAYAM SUPER MARKET (RKM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS92','SRINIVASAN STORE - RKM',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS93','RANSOM SUPERMARKET(SPM)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS94','PONNU SUPER MARKET/CAMP RD',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS95','S.K.V.STORE (CAMP ROAD)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS96','SEKAR STORES { CAMP ROAD }',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS97','JAYAM SUPER MARKET CAMP ROAD',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS98','FULFIL MART (SLR)',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCISS99','VAIRAV SUPER MARKET',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCITD-01','ITD CLAIM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCNTD-02','ITC SAMPLING',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCNTD-03','PAMS CLAIM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCNTD-04','BISCUIT CLAIM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCNTD-05','BINGO CLAIM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD1','SM TRADERS',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD10','M.P.STORE(AKP) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD11','MUTHU GANAPATHY STORE(AKP) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD12','USP STORE (AKP) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD123','PERIYANDAVAR STORE -POL',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD124','R.J .TRADERS',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD13','MURUGAN SREE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD14','MURUGAN SRI',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD15','KALI STORE.',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD16','NATIONAL AGENCIES.',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD17','MARIEAPPAN STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD18','SELVARANI STORE_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD19','MAJ BASHA STORE_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD2','ANANDHA PROVISION_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD20','NEW JAYA PROVISION_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD200','SAI MAGESHWARI AGENCIES-MAD',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD-200','A.M Lakshmi Store',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD201','MINAR STORE -MKN',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD203','JAI AKASH STORE',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD21','SAI DEEPAN STORE _WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD22','SIVAGAMI   PROVISION STORE',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD23','ANDROO STORE_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD24','THILAGAM STORE_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD25','TSM STORE',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD26','MAHALAKSHMI STORE_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD27','R.S OIL STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD28','AMBAL TRADERS (CHR)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD29','VADIVEL STORES (CHR) -C',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD3','A ONE PROVISION STORES',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD30','S.M.TRADERS CHR -B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD31','KURUTHU STORE(CHR) (V) -B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD32','N.B STORE (CHR)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD33','CHENNAI ALPHA ENTERPERISES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD34','TRI SHAKTHI LEATHER ENTERPRISES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD35','SRI SHAKTHI LEATHER ENTERPRISES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD36','THANGAM STORE-NEMILICHERY',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD37','T.K.S.PROVISION(CHR)-A WH',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD38','KAMARAJ STORE(CHR) (V) -B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD39','NADAR PROVISION(CHR) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD4','JAYAM STORE ALAN_WH',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD40','TRI SHAKTHI LEATHER ENTE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD41','NATIONAL AGENCIES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD42','RAMJI (SHANKARA SCHOOL)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD43','HAJI P.S & SONS-9551139400',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD44','KAVITHA STORE ( KPM)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD45','RED PLUS MEDICAL',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD46','ANANDA STORE(O.PLM) -C',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD47','ROJA SRI STORES(O.PLM) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD48','SM SUPER MARKET',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD49','RAJENDRA STORE PVM -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD5','SRI DURAIAPPA AGENCIES',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD50','SRI PERIYANDAVAR STORE-OPLM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD51','KAMACHI SREE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD52','SRI RAMAJEYAM STORE-OPLM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD53','U K BROTHERS (SWD)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD54','BABU STORE-PAL',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD55','MAHARAJA STORE (PLM) (V) B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD56','A.M.NAZEER (PLM) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD57','KARPAGAM SRI STORE(PLM) -B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD58','PRAKASH SWEETS M(PLM) (V) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD59','PON PANDIAN STALL(PLM) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD6','MINAR STORE.',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD60','COLOMBU STORE PVM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD61','SRI VIJAYALAKSHMI STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD62','ANNAI STORE (PLM (V) -B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD63','SRI KAMATCHI STORE--PLM-V',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD64','SNEHA CHIPS PVM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD65','S.A.F BABU STORES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD66','FAROOK BASHA STORE (PML) (V) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD67','SARAVANA STORES(PML) -C',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD68','S.M.K.KRISHNA STORE(PML) -B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD69','MEERA MALIGAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD7','SRI MAHALAKSHMI STORE',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD70','MALIGAI KADAI.COM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD71','MURUGAN SHREE - PML',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD72','AYYAN STORES(PML) -A',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD73','KARTHIGEYA PLASTICS & TECHNOLGIES PVT LTD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD74','NATIONAL ENTERPRISES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD75','M.K STORE-PML',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD76','WEL COME AGENCIES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD77','ANANDA STORE (AGRM)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD78','LINGAM STORE - SEL',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD79','VAIRAVARAJAN STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD8','SRI KAMATCHI STORE-AKP',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD80','MUTHU MEENAKSHI ENTERPRISES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD81','NEHEMIAH TRADERS',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD82','BAVANI STORE- TMVM',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD83','SRI KAMACHI STORE-VELACHERY',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD84','SRI KAMACHI STORES-VELACHERY',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD85','SRI MAHALAKSHMI AND CO',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD9','EBENEZER TRADERS',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD90','SRI AMBIGAI STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD91','S.M.K. STORE -PML',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD92','SMK STORE -PML',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCSWD93','MURUGAN SRI -PML',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN1','SRI VINAYAGAM STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN10','VADIVEL STORES (CHR)V',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN100','LINGAM SRI STORE(PLM) -SC -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN101','MURUGAN STORE(Z.PLM -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN102','MUTHARAMMAN STORE(Z.PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN103','PADMAVATHI SRI GEN.STORE(PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN104','PON LATHA STORE(ZPLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN105','R.S. STORE(ZPLM) -A-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN106','PUSHPALATHA STORE {O-PLM} -A-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN107','SARAVANA STORE(Z.PLM) -A-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN108','VIJAYA LAKSHMI PROVISION STORE (ZPLM) -A  -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN109','IMMANUEL STORE (ZPLM) -A-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN11','THIRUMURUGAN STORE-HAS-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN12','SHANMUGA STORE HPM-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN13','AAMARAVATHI STORE(O.PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN14','AMUL STORE(O.PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN15','ANNAI NEW STORE (O.PLM) -B -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN16','ARUL REVATHI STORE(OPLM) -B -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN17','AYYANAR STORE(O.PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN18','BALAJI SRI TRADERS(KIL) -B -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN19','BAVANA STORE(OPLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN2','NEW RAJA STORE AKP',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN20','BOOPATHY STORE -B ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN21','CHANDRA STORE(OPLM) -SC -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN22','CHINNA DURAI STORES (O.PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN23','GODWILL BAKER(O.PLM) - C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN24','JAYAMURUGAN(O.PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN25','KARTHIKA STORE(O.PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN26','MAHALAKSHMI PROVISION(OPLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN27','MOTHER SHOPPY (O.PLM) -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN28','MURUGAN STORE (O.PLM)-SC -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN29','MUTHU SRI SARAVANA STORE(O.PLM)-  C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN3','SRI KAMATCHI AMMAN ST-AKP-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN30','O.K.TEA STALL(O.PLM) -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN31','OM PROVISION (O.PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN32','PON RATHI STORE(O.PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN33','R.R.STORE(O.PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN34','R.S STORE(OPLM) -DE-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN35','RAMA STORE(OPLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN36','S.M.MUTHU STORE(O.PLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN37','SAMADURI STORE(O.PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN38','SARASWATHI NEW STORE (O.PLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN39','SARASWATHI STORE (O.PLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN4','P.K.STORES(AKP) (V) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN40','SHIVA STORE(OPLM) -SC-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN41','SUNDARA PANDAIYAN STORE(O.PLM) -  A _ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN42','SUNDARLINGAM STORE(O.PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN43','SUYAMBU LINGAM STORE (O.PLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN44','VASU STORE(OPLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN45','ANNAI RAJA STORE (OPVM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN46','P.T KOTHANDAM & SONS(PLM) (V) -C',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN47','REVATHI STORE(PLM) (V) -C',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN48','SARASWATHI ENTERPRISES',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN49','J.K TRADERS (PLM) -B',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN5','ZAKIRIA STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN50','A.C.A.STATIONERY-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN51','O.NABI STORE-C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN52','A.S.S.PROVISION STORE(PLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN53','A.V.N.STORE (PLM) SC -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN54','AALVIN MILK CENTRE(PLM) -SC -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN55','BABU SEEVAL(PLM) -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN56','WBALA VINAYAGAM STORE (PVM)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN57','BALAKRISHNA STORE -C -IYD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN58','BALAMURUGAN SRI STORE (PLM) -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN59','BUVANESWARI STORE(PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN6','MOHAN STORE',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN60','DECK DEVIL PROVISION STORE(PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN61','EM.EL STORE (PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN62','GOPAL SEEVAL(PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN63','HARRIS PROVISION (PLM) -A -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN64','MEENAKSHI STORE(PLM) -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN65','MOOKAMBIGAI STORE (PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN66','MURUGAN STORE PVM -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN67','MURUGAN STORE (CPLM)-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN68','MURUGAN STORE(PLM) -B -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN69','MURUGESAN FANCY(PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN7','VAIRAM COOL BAR',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN70','MUTHU GENERAL STORE(PLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN71','KAVIYA TRADERS OPLM -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN72','N.V.R.ARISI MANDY -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN73','PALLAVARAM PROVISIONAL STORE(PL M) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN74','PONLATHA STORES 2 -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN75','PR PANDIAN STORE(PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN76','S.R.A.STORE(PLM)-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN77','S.S.STORE (MGR ST) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN78','SUMITHRA STORE OPLM -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN79','SARAVANAKUMAR STORE (PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN8','VARUN ENTP. SHELL-CHROMPET',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN80','SELVAJOTHI PROVISION STORES(PLM) -B -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN81','SENTHIL STORE (PLM) -C-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN82','SRINIVASA PERUMAL SEEVAL NADDU MUTHU-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN83','SRINIVASA SEEVAL(PLM) -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN84','SUNDARRAJ MALIGAI(OPLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN85','SUSEEL STORE(PLM)-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN86','SUYAMBU STORE(PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN87','THANGARAJ MALIGAI PVM-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN88','THIRUMURUGAN(PLM) -B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN89','VIJAY STORES -A-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN9','S.M.TRADERS-CHR',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN90','A.G.PANDIAN STORE (PLM)-B-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN91','MA COOL BAR-ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN92','A.J STORE(POZ)(V)',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN93','LAKSHMI STORE(TRM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN94','RAGAVENDRA SRI STORES(TRM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN95','A.T.R.STORE(PLM) -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN96','AJANTHA NEW SWEETS(Z.PLM) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN97','AMBAL STORE (ZP) -C -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN98','GAYATHRI STORE(Z.PLM) -B -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCVAN99','KAMARAJ STORE(Z.PLM) -B -ITD',5,21
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARC-WD-01','CORTEX ENTERPRISES -W',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ARCWD-01','CORTEX ENTERPRISES',5,20
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C10000001','popular medical',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C10000002','popular medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C10000003','lalitha medical-PLM',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C10000004','s.m medicals-plm',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C10000005','s.m medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C10000006','shakthi pharmacy',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C11000001','Thula exports Private limited',3,13
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C12000001','kalai selvi',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C12000002','karthik store-mgr',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C14000001','VINAYAGA STORS',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C14000002','GRAND BAKERY',2,1
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C21000001','Jayam seeval store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C21000002','Dailyrate',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C21000003','NSM',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C21000004','SELVA RANI STORE',2,8
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C21000005','THIRUMAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C21000008','SRI MAGESWARI SRORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C22000001','HAASAN store',2,16
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C25000001','muthulakshmi store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C25000002','shanthi store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C25000003','Rasu store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C25000004','S S store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C28000002','sri pachaiammal department store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C3000001','sri Ponvandu ayyanar store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C3000002','kumaran store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C3000003','keetharam',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C33000001','kannan store CHR',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C33000002','NK STORES',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C5000002','Ramesh Store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C5000003','Muthu lakshmi store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C8000001','pammal saravana shopping',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C90000001','Arisival store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C91000001','Vinayaga store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C91000002','ROJA NATTU MARUNTHU KADAI',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C91000003','ANJANEYA Pooja stores',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C91000005','RAJA SEAVAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C91000006','A.R SEEVAL STORE',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C92000005','Indra store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C92000006','vijaya laxmi store',2,11
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000001','medway',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000002','marundhagam',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000003','shri sabari',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000004','Sri Ayyanar medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000005','Amman medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000006','Essaar Medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000007','Sri Lakshmi Pharmacy',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000008','Sri Dhanalakshmi Medical & Distrbutor',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000009','Gokul Medical',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000010','Sri Muthu Pharmacy',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000011','Chennai Medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000012','Sri Ganesh Pooja storie',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000013','Sri Krishna medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000014','Abi Medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000015','A V Medical Stores',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000016','Tulasi Medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000017','A K plaza',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000018','Sri senthur Murgan nattu maranthu kaadai',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000019','K K Medicals',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000020','S S M Nattu marnthu kaadai',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000021','RADHA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000022','AMBHIKA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000023','M.S MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000024','FRIENDS MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000025','NEW ROJA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000026','GOKUL MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000027','MURUGAN MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000028','SRI RAGAVENDRA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000030','ABIRAMI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000031','Chitra Pharmacy',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000032','BALAJI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000033','SELVI MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000034','PADMA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000035','GEETHA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000036','VARSHA MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000037','ALAGU PHARMACY',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000038','JAN AUSHADHI MEDICAL',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'C94000039','SHRI SAIRAM MEDICALS',2,3
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'CNTRT0001','Counter Retail',2,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'CNTRW0001','Counter RuralSWD',2,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'CNTTW0001','Counter TownSWD',2,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'EXPL-18RHR0037','BHARATH COLLAGE BOYS CANTEEN',2,2
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE1113','JAYANTHI STORE(Z.PLM) -A',2,15
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE1281','SINGAPORE SHOPPEE(PLM) -A',2,15
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE1337','WONDERS(PLM) -A',2,15
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE2274','SRI SHANMUGA SUPER SHOPPEE-PLM',2,15
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE3099','SETTAI AMMAN PROVISION',1,12
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE3158','MANI RAJ STORE (CHR) -B',2,15
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE6035','BHAKIYAM STORE -A',2,15
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE6193','RAJAN STORE (CHR) -A',2,14
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GCE9035','A.NISAR AHMEED',2,12
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'GREATSANDS','GREAT SANDS CONSULTING PRIVATE LIMITED',2,19
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'ITC001Outlet','ITC Limited',4,5
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'PPMS','PPMS FIELD MARKETING PVT. LTD',2,19
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'RHR1624','BUVANA CATERING(SLR)',2,2
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'RHR7975-NEW2016','S.K. FOODS',2,2
insert into Customer_Mappings(CustomerID, Company_Name, CategoryGroupId, GroupId) Select 'RHR8235-NEW2017','SWATHY CATERING',2,2
GO
