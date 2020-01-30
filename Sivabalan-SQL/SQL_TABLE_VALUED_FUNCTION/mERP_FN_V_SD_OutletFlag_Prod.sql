Create Function mERP_FN_V_SD_OutletFlag_Prod()
Returns
@outPut Table(ProdDefnID int,Products nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,Product_code nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID int)
AS
BEGIN

Declare @tmpOP Table(ProdDefnID int,Products nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,Product_code nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID int)
Declare @curProddefnid as Table (ProdDefnID int)
Declare @TmpCatGroup as Table (ProdDefnId int, GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Declare @OCGGlag As Int
Set @OCGGlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

Declare @HHDS Table (SalesmanID int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert into @HHDS
Select S.SalesmanID,C.CustomerID From 
Beat_Salesman BS, Salesman S, Beat B,Customer C,DSType_Details dd, DSType_Master dm
Where 
DM.DSTypeCTLPos = 2 And
DD.DSTypeCTLPos = 2 And
isnull(B.Active,0) = 1 And
isnull(Dm.Active,0)=1 And 
isnull(C.Active,0) = 1 And
DM.DSTypeValue = 'Yes' And
DD.SalesmanID =S.SalesmanID And
S.SalesmanId = BS.SalesmanId And 
dd.DSTypeID = dm.DSTypeID And 
C.CustomerID = BS.CustomerID And 
isnull(S.Active,0) = 1 And 
B.BeatId = BS.BeatId

Declare @GGDRMonth as DateTime
Set @GGDRMonth = dbo.striptimefromdate(getdate())

insert into @curProddefnid (ProdDefnID)
Select Distinct ProdDefnId From GGDROutlet Where @GGDRmonth between ReportFromdate and ReportTodate
And OutletID in (Select Distinct CustomerID From @HHDS)

insert into @tmpOP(ProdDefnID,Products,Product_code)
select Distinct T.ProdDefnID,G.Products,T.Product_code from GGDRProduct G,TmpGGDRSKUDetails T,ItemCategories IC
Where G.ProdDefnId=T.ProdDefnId And
IC.Category_Name=T.Division And
G.Products = T.Division And
G.ProdCatLevel=2 and
G.Products <> 'ALL'And
isnull(IC.active,0)=1 and G.ProdDefnID in (select ProdDefnID from @curProddefnid)
Union ALL
select Distinct T.ProdDefnID,G.Products,T.Product_code from GGDRProduct G,TmpGGDRSKUDetails T,ItemCategories IC
Where G.ProdDefnId=T.ProdDefnId And
IC.Category_Name=T.SubCategory And
G.Products = T.SubCategory And
G.ProdCatLevel=3 and
G.Products <> 'ALL' And
isnull(IC.active,0)=1 and G.ProdDefnID in (select ProdDefnID from @curProddefnid)
Union ALL
select Distinct T.ProdDefnID,G.Products,T.Product_code from GGDRProduct G,TmpGGDRSKUDetails T,ItemCategories IC
Where G.ProdDefnId=T.ProdDefnId And
IC.Category_Name = T.MarketSKU And
G.Products = T.MarketSKU And
G.ProdCatLevel=4 and
G.Products <> 'ALL' And
isnull(IC.active,0)=1 and G.ProdDefnID in (select ProdDefnID from @curProddefnid)
UNION ALL
Select Distinct G.ProdDefnID,G.Products,G.Products from GGDRProduct G,Items I Where
G.Products =I.Product_code And
G.ProdCatLevel=5 and
G.Products <> 'ALL' And
Isnull(I.Active,0)=1 and G.ProdDefnID in (select ProdDefnID from @curProddefnid)

Insert Into @TmpCatGroup(ProdDefnId,GroupName)
Select Distinct ProdDefnId,Isnull((Case When @OCGGlag = 0 Then CatGroup When @OCGGlag = 1 Then OCG End),'All') 
From GGDROutlet Where ProdDefnID in (Select ProdDefnID from GGDRProduct where Products='ALL') 
And @GGDRmonth Between ReportFromdate and ReportTodate

insert into @tmpOP(ProdDefnID,Products,Product_code)
Select T.ProdDefnId,Temp.Division,Temp.Product_code from TmpGGDRSKUDetails Temp,@TmpCatGroup T,Items I
Where T.ProdDefnId = Temp.ProdDefnId And
Temp.Product_code=I.Product_code And
T.GroupName=Temp.CategoryGroup And
Isnull(I.Active,0)=1 And
T.GroupName <> 'ALL' and Temp.ProdDefnID in (select ProdDefnID from @curProddefnid)

insert into @tmpOP(ProdDefnID,Products,Product_code)
Select T.ProdDefnId,Temp.Product_code,Temp.Product_code from TmpGGDRSKUDetails Temp,@TmpCatGroup T,Items I
Where T.ProdDefnId = Temp.ProdDefnId And
Temp.Product_code=I.Product_code And
Isnull(I.Active,0)=1 And
T.GroupName = 'ALL' and Temp.ProdDefnID in (select ProdDefnID from @curProddefnid)

Update T Set T.CategoryID=V.Category_ID from @tmpOP T,V_Category_Master V
Where T.Products=V.Category_Name

Insert into @outPut
Select Distinct ProdDefnID,Products,Product_Code,CateGoryID From @tmpOP Order By ProdDefnID,Products,CateGoryID,Product_Code

Delete From @outPut Where ProdDefnID Not in (Select Distinct ProdDefnID From @curProddefnid)

Return
END
