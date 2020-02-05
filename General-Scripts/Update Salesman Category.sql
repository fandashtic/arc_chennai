Update SalesmanCategory Set SalesmanCategoryName = 'Atta' Where SalesmanCategoryId =1
Update SalesmanCategory Set SalesmanCategoryName = 'Bingo' Where SalesmanCategoryId =2
Update SalesmanCategory Set SalesmanCategoryName = 'Biscuits' Where SalesmanCategoryId =3
Update SalesmanCategory Set SalesmanCategoryName = 'Chemist-1' Where SalesmanCategoryId =4
Update SalesmanCategory Set SalesmanCategoryName = 'Common' Where SalesmanCategoryId =5
Update SalesmanCategory Set SalesmanCategoryName = 'ISS' Where SalesmanCategoryId =6
Update SalesmanCategory Set SalesmanCategoryName = 'PCP' Where SalesmanCategoryId =7
Update SalesmanCategory Set SalesmanCategoryName = 'SWD' Where SalesmanCategoryId =8
IF Not Exists(select  top 1 1 from SalesmanCategory Where SalesmanCategoryName = 'Chemist-2')
begin
	Insert into SalesmanCategory (SalesmanCategoryName) select 'Chemist-2'
end
GO
Update SalesmanCategory Set SalesmanCategoryName = 'Chemist-2' Where SalesmanCategoryId =9
GO
Update Salesman Set SalesmanCategoryId = 8 Where Salesman_Name ='GANESH-7904770367'
Update Salesman Set SalesmanCategoryId = 6 Where Salesman_Name ='SATHYA-8072137232'
Update Salesman Set SalesmanCategoryId = 6 Where Salesman_Name ='SATHISH.S-8667603953'
Update Salesman Set SalesmanCategoryId = 6 Where Salesman_Name ='SANKAR-9940089579'
Update Salesman Set SalesmanCategoryId = 3 Where Salesman_Name ='PANDY-9003170658'
Update Salesman Set SalesmanCategoryId = 3 Where Salesman_Name ='SALMAN-8056097123'
Update Salesman Set SalesmanCategoryId = 3 Where Salesman_Name ='ROHIT-9042121704'
Update Salesman Set SalesmanCategoryId = 3 Where Salesman_Name ='V.SURESH BABU-9840888874'
Update Salesman Set SalesmanCategoryId = 3 Where Salesman_Name ='SAMSON-8778869819'
Update Salesman Set SalesmanCategoryId = 3 Where Salesman_Name ='PRABHU.V-9952911919'
Update Salesman Set SalesmanCategoryId = 2 Where Salesman_Name ='AKASH.S.K-7010195569'
Update Salesman Set SalesmanCategoryId = 2 Where Salesman_Name ='VIVEK.N-9941555675'
Update Salesman Set SalesmanCategoryId = 2 Where Salesman_Name ='FAIROZ-7993423550'
Update Salesman Set SalesmanCategoryId = 2 Where Salesman_Name ='PURUSHOTHKUMAR-8939630332'
Update Salesman Set SalesmanCategoryId = 2 Where Salesman_Name ='RAKESH-8778092379'
Update Salesman Set SalesmanCategoryId = 2 Where Salesman_Name ='M.AATHI RAM-8608975380'
Update Salesman Set SalesmanCategoryId = 1 Where Salesman_Name ='UMA MAHESH-9941240259'
Update Salesman Set SalesmanCategoryId = 1 Where Salesman_Name ='GUNA-9600191547'
Update Salesman Set SalesmanCategoryId = 1 Where Salesman_Name ='SOLAIRAJ-8778342219'
Update Salesman Set SalesmanCategoryId = 1 Where Salesman_Name ='P.SARAVANAN-9790848252'
Update Salesman Set SalesmanCategoryId = 1 Where Salesman_Name ='DHANACHEZIAN-7397440621'
Update Salesman Set SalesmanCategoryId = 1 Where Salesman_Name ='NAGARAJ-6383388071'
Update Salesman Set SalesmanCategoryId = 5 Where Salesman_Name ='ROGAN-7550245540'
Update Salesman Set SalesmanCategoryId = 7 Where Salesman_Name ='RAJAPANDI-9884102392'
Update Salesman Set SalesmanCategoryId = 7 Where Salesman_Name ='SURYA-9566033024'
Update Salesman Set SalesmanCategoryId = 7 Where Salesman_Name ='RAJESH-8807423437'
Update Salesman Set SalesmanCategoryId = 7 Where Salesman_Name ='NAVEEN KUMAR-9941524783'
Update Salesman Set SalesmanCategoryId = 7 Where Salesman_Name ='HARIKRISHNA RAJ-9003734479'
Update Salesman Set SalesmanCategoryId = 7 Where Salesman_Name ='KARTHICK.M-9940561690'
Update Salesman Set SalesmanCategoryId = 4 Where Salesman_Name ='VIGNESH.D-9840775458'
Update Salesman Set SalesmanCategoryId = 9 Where Salesman_Name ='BHARATH-9514559071'
GO
