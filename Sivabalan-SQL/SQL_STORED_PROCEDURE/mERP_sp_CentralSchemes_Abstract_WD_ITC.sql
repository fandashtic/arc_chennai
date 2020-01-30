CREATE PROCEDURE mERP_sp_CentralSchemes_Abstract_WD_ITC
(
@CategoryGroup nVarChar(2550),@ProductHierarchy nVarchar(510),
@Category nVarchar(2550),@Channels nVarChar(2550),
@SalesMan nVarChar(2550),@Beat nVarChar(2550),
@Customers nVarChar(2550),@ReportLevel nVarChar(50),
@DiscType nVarchar(50),@UOM nVarChar(10),
@FromDate DateTime,@ToDate DateTime,
@Claimable nVarChar(5),@FreeValAt nVarchar(5)
)
AS

Declare @CatID Int  
Declare @CatName nVarChar(255)  
Declare @SchID Int  
Declare @SchName nVarChar(255)  
Declare @SchValue Decimal(18,6)  
Declare @SqlStat nVarChar(Max)  
Declare @SchList nVarChar(Max)  
  
Declare @Delimeter nVarchar(1)  
Set @Delimeter = Char(15)  
  
Create Table #TempCategory     (CategoryID Int, Status Int)  
Create Table #TempSelectedCats (CatID int , CatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #TempSelCatsLeaf  (SelCat int, SelCatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,LeafCat int)  
Create Table #TempChannels     (ChannelType int)  
Create Table #TempSalesMans    (SalesManID int)  
Create Table #TempBeats        (BeatID int)  
Create Table #TempCust         (CustomerID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #TempAllSchemes   (SchemeID int,SchemeName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #TempSchemes      (SchemeID int)  
  
If @ReportLevel <> N'Category Wise' And @ReportLevel <> N'Channel Wise' And @ReportLevel <> 'DS wise' And @ReportLevel <> 'Beat wise' And @ReportLevel <> 'Customer wise'  
Set @ReportLevel = 'Category Wise'  
  
--If @DiscType <> 'Scheme' And @DiscType <> 'Product Discount' And @DiscType <> 'Addl. Discount' And @DiscType <> 'Trade Discount' And @DiscType <> 'Only Free Item' And @DiscType <> 'All without Free Item'  
If @DiscType <> 'Scheme' And @DiscType <> 'Trade Discount' And @DiscType <> 'Only Free Item' And @DiscType <> 'All without Free Item'  
Set @DiscType = 'All without Free Item'  
  
If @UOM <> N'Base UOM' And @UOM <> N'UOM1' And @UOM <> N'UOM2'  
Set @UOM = 'UOM2'  
  
If @Claimable <> 'Yes' And @Claimable <> 'No' And @Claimable <> 'Both'  
Set @Claimable = 'Both'  
  
If @FreeValAt <> 'PTS' And @FreeValAt <> 'PTR'  
Set @FreeValAt = 'PTS'  
  
If @ProductHierarchy = N'%' Or @ProductHierarchy = N'Division'  
Set @ProductHierarchy = (select Distinct HierarchyName from ItemHierarchy where HierarchyID = 2)  
  
Exec Sp_GetCGLeafCategories_ITC @CategoryGroup,@ProductHierarchy,@CATEGORY   
  
Insert Into #TempSelCatsLeaf (LeafCat) Select Distinct CategoryID From #TempCategory  
  
If @Category = '%'  
 Insert into #TempSelectedCats Select CategoryID,Category_Name from ItemCategories  
 Where [Level] = (Select HierarchyID From ItemHierarchy Where HierarchyName = @ProductHierarchy)  
Else  
 Insert into #TempSelectedCats Select CategoryID,Category_Name from ItemCategories  
 Where Category_Name In (select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))  
  
Declare SelCatLeafCat Cursor For Select CatID,CatName from #TempSelectedCats  
Open SelCatLeafCat  
Fetch From SelCatLeafCat Into @CatID,@CatName  
 While @@Fetch_Status = 0   
  Begin  
   Delete from #TempCategory  
   Exec GetLeafCategories @ProductHierarchy, @CatName  
   Update #TempSelCatsLeaf Set SelCat = @CatID ,SelCatName = @CatName  
   Where LeafCat in (Select CategoryID from #TempCategory)  
   Fetch Next From SelCatLeafCat Into @CatID,@CatName  
  End  
Close SelCatLeafCat  
Deallocate SelCatLeafCat  
  
If @Channels = '%'  
 Insert Into #TempChannels  
 Select Distinct ChannelType from Customer_Channel  
Else  
 Insert Into #TempChannels  
 Select Distinct ChannelType from Customer_Channel  
  Where ChannelDesc In (Select * from  Dbo.sp_SplitIn2Rows(@Channels,@Delimeter))  
  
If @SalesMan = '%'                
 Insert Into #TempSalesMans  
 Select Distinct SalesManID From SalesMan                
Else                
 Insert Into #TempSalesMans  
 Select Distinct SalesManId From SalesMan   
 Where SalesMan_Name In (Select * From Dbo.sp_SplitIn2Rows(@SalesMan,@Delimeter))  
                
If @Beat = '%'                 
 Insert Into #TempBeats  
 Select Distinct BeatId From Beat                
Else   
 Insert Into #TempBeats  
 Select Distinct BeatId From Beat Where Description In ( Select * From Dbo.sp_SplitIn2Rows(@Beat,@Delimeter))  
          
If @Customers = '%'  
 Insert Into #TempCust  
 Select Distinct CustomerID from Customer  
Else  
 Insert Into #TempCust  
 Select Distinct CustomerID from Customer  
 Where Company_Name In (Select * from Dbo.sp_SplitIn2Rows(@Customers,@Delimeter))  
  
-- Select * from #TempCategory  
-- Select * from #TempSelectedCats  
-- Select * from #TempSelCatsLeaf  
-- Select * from #TempChannels  
-- Select * from #TempSalesMans  
-- Select * from #TempBeats  
-- Select * from #TempCust  
  
Create Table #TempSale  
(   
 RowID Int Identity(1,1), SelCat Int,  
 SelCatName nVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,  
 CatID int,  
 Channel int,SalesManID int,Beat int,  
 CustomerID nVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,       
 ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,  
 UOM int,UOM1 int,UOM2 int,  
 Serial nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 Free Decimal(18,6),  
 FreeValue Decimal(18,6),  
 SchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SchQty nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SchValue nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SumSchValue Decimal(18,6),  
 SplSchItem_Code nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SplSchQty nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SPlSchValue nVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SumSPlSchValue Decimal(18,6),  
  
 SplFlag nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 TotQty Decimal(18,6),  
 NetValue Decimal(18,6),  
 DiscSalValue Decimal(18,6),  
 SDiscSalValue Decimal(18,6),  
  
 ClaimableInvSch int,  
 InvSchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 InvSchemeValue nVarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  
 ClaimableSch Int,  
 SchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SchemeValue nVarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  
 ClaimableSplSch Int,  
 SplCatSchemeID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SplCatSchemeValue nVarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  
 SNetValue Decimal(18,6),  
 TNetValue Decimal(18,6),  
 TDisc Decimal(18,6),  
 MUOM nVarChar(2000),

 SplCatRowsCount Int Default 0,
 ItemRowsCount Int Default 0,
 InvSchRowCount Int Default 0 
)  
  
if @DiscType = 'Only Free Item'  
 Begin  
  Insert Into #TempSale  
   (SelCat,SelCatName,CatID,Channel,SalesManID,Beat,CustomerID,  
   ItemCode,UOM,UOM1,UOM2,Serial,Free,FreeValue)  
  Select  
   Cat.SelCat,  
   Cat.SelCatName,  
   Cat.LeafCat,  
   C.ChannelType,  
   IA.SalesManID,  
   IA.BeatID,  
   IA.CustomerID,  
   I.Product_Code,  
   Max(I.UOM),Max(I.UOM1),Max(I.UOM2),  
   Cast(IDT.Serial as Varchar(100)),  
   (sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End)),  
   (Sum(IDT.Quantity) * (Case @FreeValAt When 'PTR' Then Max(IDT.PTR) Else Max(IDT.PTS) End))  
  From      
   InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat  
  Where   
   IA.Status & 128 = 0  
   And IA.InvoiceType in (1,3)  
   And IA.InvoiceDate Between @FromDate And @ToDate  
   And IA.SalesmanID In (Select SalesManID From #TempSalesMans)  
   And IA.BeatID In (Select BeatID From #TempBeats)  
    And IA.CustomerID In (Select CustomerID From #TempCust)  
 And C.ChannelType In (Select ChannelType From #TempChannels)  
   And IDT.FlagWord = 0  
   And IDT.SalePrice = 0  
   And IA.InvoiceID = IDT.InvoiceID     
   And I.Product_Code = IDT.Product_Code  
    And I.CategoryID = Cat.LeafCat  
    And IA.CustomerID = C.CustomerID  
  Group By  
   Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID,   
   IA.CustomerID,IDT.InvoiceID,IA.InvoiceType,I.Product_Code,IDT.Serial   
 End  
Else  
 Begin  

  Insert Into #TempSale  
   (SelCat,SelCatName,CatID,Channel,SalesManID,Beat,CustomerID,  
   ItemCode,UOM,UOM1,UOM2,Serial,  
   SchItem_Code,SchQty,SchValue,SumSchValue,  
   SplSchItem_Code,SplSchQty,SplSchValue,SumSplSchValue,SplFlag,  
   TotQty,NetValue,SDiscSalValue,   
   ClaimableInvSch,InvSchemeID, InvSchemeValue,  
   ClaimableSch, SchemeID, SchemeValue,  
   ClaimableSplSch ,SplCatSchemeID, SplCatSchemeValue, 
   TNetValue,TDisc)   
   --PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)  
  Select  
   Cat.SelCat,  
   Cat.SelCatName,  
   Cat.LeafCat,  
   C.ChannelType,  
   IA.SalesManID,  
   IA.BeatID,  
   IA.CustomerID,  
   I.Product_Code,  
   Max(I.UOM),Max(I.UOM1),Max(I.UOM2),  
   Cast(IDT.Serial as nVarchar(100)) 'Serial',  
   /* Multiple Products Can be Show with [|] sign */    
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 1, 1,I.Product_Code,IDT.Serial) 'SchItem_Code',  
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 2, 1,I.Product_Code,IDT.Serial) 'SchQty',  
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 3, 1,I.Product_Code,IDT.Serial) 'SchValue',  
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.FreeSerial), @FreeValAt, 4, 1,I.Product_Code,IDT.Serial) 'SumSchValue',  
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 1, 2,I.Product_Code,IDT.Serial) 'SplSchItem_Code',  
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 2, 2,I.Product_Code,IDT.Serial) 'SplSchQty',  
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 3, 2,I.Product_Code,IDT.Serial) 'SplSchValue',  
   dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, Max(IDT.SplCatSerial), @FreeValAt, 4, 2,I.Product_Code,IDT.Serial) 'SumSplSchValue',  
-- (Select Min(Cast((Case When CharIndex(',',SplCatSerial) > 0 Then Left(SplCatSerial,CharIndex(',',SplCatSerial)-1) Else SplCatSerial End) As Int)) from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Cast(Serial as nVarchar(100)) = Cast(Case When CharIndex(',',Max(IDT.SplCatSerial)) > 0 Then Left(Max(IDT.SplCatSerial),CharIndex(',',Max(IDT.SplCatSerial))-1) Else Max(IDT.SplCatSerial) End As Int)) 'SplFlag',  
    (Select Case When Flagword=1 And Len(IsNull(FreeSerial,'')) > 0 then Min(FreeSerial) 
                When Flagword=1 And Len(IsNull(SplCatSerial,'')) > 0 then Min(SplCatSerial) 
                Else '' End
    from InvoiceDetail Where InvoiceID = IDT.InvoiceID 
    and Cast(Serial as nVarchar(100)) in (
        Case When IDT.Flagword=1 And Len(IsNull(IDT.FreeSerial,'')) > 0 then (IsNull(Min(IDT.FreeSerial),'')) 
                When IDT.Flagword=1 And Len(IsNull(IDT.SplCatSerial,'')) > 0 then (IsNull(Min(IDT.SplCatSerial),'')) Else '' End) Group by Flagword, IsNull(SplCatSerial,''),IsNull(FreeSerial,'')) 'SplFlag',
   --(Select SplCatSerial from InvoiceDetail Where InvoiceID = IDT.InvoiceID And Cast(Serial as nVarchar(100)) in (IsNull(Max(IDT.SplCatSerial),''))) 'SplFlag',  
   Sum(IDT.Quantity) / (Case @UOM when 'UOM2' Then (Case Max(I.UOM2_Conversion) when 0 Then 1 Else Max(I.UOM2_Conversion) End) When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 Then 1 Else Max(I.UOM1_Conversion) End) Else 1 End),  
   Max(IDT.Amount),   
   /* Invoice Scheme Column Changed*/  
   (Case When (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 Or Max(IA.SchemeDiscountPercentage) > 0) Or Max(IDT.SplCatSchemeID) > 0 Or Max(IDT.SchemeID)>0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice)) - (Case When Max(IDT.SplCatSchemeID) = 0 And Len(IsNull(IA.InvoiceSchemeID,'')) = 0 Then Max(IDT.DiscountValue) Else 0 End) Else 0 End),  
   /*RFA Claimable*/  
   Case Len(dbo.merp_fn_List_CSIDByRFA(IA.InvoiceSchemeID,'Yes')) When 0 Then 0 Else 1 End 'ClaimableInvSch',  
   Case @Claimable   
     When 'Both' Then (Case When (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 OR Max(IA.SchemeDiscountPercentage) > 0) Then (IA.InvoiceSchemeID) Else '0' End)  
     Else (Case When (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 OR Max(IA.SchemeDiscountPercentage) > 0) Then dbo.merp_fn_List_CSIDByRFA(IA.InvoiceSchemeID,@Claimable) Else '0' End) End 'InvSchemeID',   
     Case When 
         (Len(IsNull(IA.InvoiceSchemeID,'')) = 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 
        When
         (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) > 0) Then (dbo.merp_fn_Get_CSValueByRFA(IsNull(IA.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) + Char(15) + dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial))
        When 
         (Len(IsNull(IA.InvoiceSchemeID,'')) > 0 AND Max(IA.SchemeDiscountPercentage) = 0) Then dbo.merp_fn_Get_MultipleCSFreeInfo(IDT.InvoiceID, IsNull(IA.InvoiceSchemeID,''), @FreeValAt, 1, 3,I.Product_Code,IDT.Serial) Else '0' End 'InvSchemeValue',  
  
   Case Len(dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSchemeID,''),'Yes')) When 0 Then 0 Else 1 End 'ClaimableSch',  
   Case @Claimable   
   When 'Both' Then IsNull(IDT.MultipleSchemeID,'')  
   Else dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSchemeID,''),@Claimable) End 'SchemeID',   
   dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSchemeDetails,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 'SchemeValue',   
  
   Case Len(dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSplCatSchemeID,''),'Yes')) When 0 Then 0 Else 1 End 'ClaimableSplSch',   
   Case @Claimable   
     When 'Both' Then IsNull(IDT.MultipleSplCatSchemeID,'')  
     Else dbo.merp_fn_List_CSIDByRFA(IsNull(IDT.MultipleSplCatSchemeID,''),@Claimable) End 'SplCatSchemeID',   
     dbo.merp_fn_Get_CSValueByRFA(IsNull(IDT.MultipleSplCategorySchDetail,''),@Claimable,IDT.InvoiceID,I.Product_Code,IDT.Serial) 'SplCatSchemeValue',  
   /*End of RFA Claimable*/  
  
   -- PNetValue,PDisc,ANetValue,ADisc,TNetValue,TDisc)  
   --(Case When (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) > 0 Then Sum(IDT.Quantity) * Max(IDT.SalePrice) Else 0 End),  
   --((Sum(IDT.Quantity) * Max(IDT.SalePrice)) * (Max(IDT.DiscountPercentage)-Max(IDT.SchemeDiscPercent)-Max(IDT.SplCatDiscPercent)) /100),  
   (Case When Max(IA.AdditionalDiscount) >0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue) Else 0 End),  
   (((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.AdditionalDiscount)) / 100)  
   --(Case When (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) > 0 Then (Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue) Else 0 End),  
   --(((Sum(IDT.Quantity) * Max(IDT.SalePrice))-Max(IDT.DiscountValue)) * (Max(IA.DiscountPercentage)-Max(IA.SchemeDiscountPercentage)) / 100)  
  From      
   InvoiceAbstract IA, InvoiceDetail IDT, Items I, Customer C, #TempSelCatsLeaf Cat  
  Where   
   IA.Status & 128 = 0  
   And IA.InvoiceType in (1,3)  
   And IA.InvoiceDate Between @FromDate And @ToDate  
   And IA.SalesmanID In (Select SalesManID From #TempSalesMans)  
   And IA.BeatID In (Select BeatID From #TempBeats)  
   And IA.CustomerID In (Select CustomerID From #TempCust)  
   And C.ChannelType In (Select ChannelType From #TempChannels)  
   And IDT.FlagWord = 0  
   And IDT.SalePrice > 0  
   And IA.InvoiceID = IDT.InvoiceID     
   And I.Product_Code = IDT.Product_Code  
   And I.CategoryID = Cat.LeafCat  
   And IA.CustomerID = C.CustomerID  
  Group By  
   Cat.SelCat, Cat.SelCatName, Cat.LeafCat, C.ChannelType, IA.SalesManID, IA.BeatID, IA.MultipleSchemeDetails,  
   IDT.MultipleSchemeID, IDT.MultipleSchemeDetails, IDT.MultipleSplCatSchemeID, IDT.MultipleSplCategorySchDetail,  
   IA.CustomerID,IDT.InvoiceID,IA.InvoiceType,I.Product_Code,IA.InvoiceSchemeID,IA.SchemeDiscountPercentage,
	IDT.Serial, IDT.SplCatSerial, IDT.FreeSerial, IDT.Flagword --, IDT.SchemeID, IDT.SplCatSchemeID  

    
  Update #TempSale Set SchemeID= '' Where IsNull(SchItem_Code,'') = '' And IsNull(SchQty,0) = 0 And IsNull(SchemeValue,'') = ''  
  Update #TempSale Set SplCatSchemeID = '' Where IsNull(SplSchItem_Code,'') = '' And IsNull(SplSchQty,0) = 0 And IsNull(SplCatSchemeValue,'') = ''  
 

  If @Claimable = 'Yes'    
    Update #TempSale Set SNetValue = IsNull(SDiscSalValue,0)  
    Where (Len(IsNull(InvSchemeID,'')) > 0 And IsNull(ClaimableInvSch,0) = 1) Or   
       (Len(IsNull(SchemeID,'')) > 0 And  IsNull(ClaimableSch,0) = 1) Or   
       (Len(IsNull(SplCatSchemeID,'')) > 0 And IsNull(ClaimableSplSch,0) = 1)  
  Else If @Claimable = 'No'  
    Update #TempSale Set SNetValue = IsNull(SDiscSalValue,0)  
    Where (Len(IsNull(InvSchemeID,'')) > 0 And IsNull(ClaimableInvSch,0) = 0) Or   
       (Len(IsNull(SchemeID,'')) >0 And  IsNull(ClaimableSch,0) = 0) Or   
       (Len(IsNull(SplCatSchemeID,'')) > 0 And IsNull(ClaimableSplSch,0) = 0)  
  Else  
    Update #TempSale Set SNetValue = IsNull(SDiscSalValue,0)  

  Declare @TmpSchemesID Table (SchemeIDLst nVarchar(100))  
  Insert into @TmpSchemesID  
  Select IsNull(SchemeID,'') from #TempSale Where IsNull(SchemeID,N'') <> N''  
  Union   
  Select IsNull(SplCatSchemeID,N'') from #TempSale Where IsNull(SplCatSchemeID,N'') <> N''  
  Union  
  Select IsNull(InvSchemeID,N'') from #TempSale Where IsNull(InvSchemeID,N'') <> N''  
  
  Declare @SchemeIdLst nVarchar(100)  
  Declare CurTempSchIdLst Cursor For  
  Select SchemeIDLst From @TmpSchemesID  
  Open CurTempSchIdLst  
  Fetch Next From CurTempSchIdLst Into @SchemeIdLst  
  While @@FEtch_Status = 0   
    Begin  
      Insert Into #TempSchemes   
      Select ItemValue from dbo.Sp_SplitIn2Rows(@SchemeIdLst,',') Where ItemValue > 0 And ItemValue not In (Select SchemeID From #TempSchemes)  
      Fetch Next From CurTempSchIdLst Into @SchemeIdLst  
    End  
  Close CurTempSchIdLst   
  Deallocate CurTempSchIdLst  
  
  If @Claimable = 'Yes'  
    Insert Into #TempAllSchemes   
    Select Distinct #TempSchemes.SchemeID,Schemes.Cs_RecSchID + '_'+ Schemes.Description   
    from #TempSchemes,tbl_merp_SchemeAbstract Schemes  
    Where #TempSchemes.SchemeID > 0  
    And Schemes.RFAApplicable = 1  
    And #TempSchemes.SchemeID = Schemes.SchemeID  
  Else If @Claimable = 'No'  
    Insert Into #TempAllSchemes   
    Select Distinct #TempSchemes.SchemeID,Schemes.Cs_RecSchID + '_'+ Schemes.Description   
    from #TempSchemes,tbl_merp_SchemeAbstract Schemes  
    Where #TempSchemes.SchemeID > 0  
    And Schemes.RFAApplicable = 0  
    And #TempSchemes.SchemeID = Schemes.SchemeID  
  Else  
    Insert Into #TempAllSchemes   
    Select Distinct #TempSchemes.SchemeID,Schemes.Cs_RecSchID + '_'+ Schemes.Description   
    from #TempSchemes,tbl_merp_SchemeAbstract Schemes  
    Where #TempSchemes.SchemeID > 0  
    And #TempSchemes.SchemeID = Schemes.SchemeID  

  /*Update TmpSal Set tmpSal.ItemRowsCount = tItemsal.ItemSchRowsCount
  From #TempSale TmpSal,
  (Select Channel,SalesManID, Beat,CustomerID,ItemCode, SchemeValue,SchemeID,InvSchemeID , InvSchemeValue , SplCatSchemeID , SplCatSchemeValue,SchItem_Code,SplSchItem_Code,SplSchQty, Count(cast(Channel as varchar) + cast(SalesManID as varchar) + cast(Beat as varchar) + CustomerID + ItemCode +  SchemeValue + SCHEMEID + InvSchemeID + InvSchemeValue + SplCatSchemeID + SplCatSchemeValue + SchItem_Code + SplSchItem_Code + SplSchQty) as 'ItemSchRowsCount'
  From #TempSale WHERE (ISNULL(SCHEMEID,'') <> '' ) Group By Channel,SalesManID, Beat,CustomerID , ItemCode, SchemeValue,SchemeID,InvSchemeID , InvSchemeValue , SplCatSchemeID , SplCatSchemeValue,SchItem_Code,SplSchItem_Code,SplSchQty) tItemSal
  Where tmpSal.ItemCode = tItemSal.ItemCode 
  And tmpSal.CustomerID=tItemSal.CustomerID
  And tmpSal.Channel=tItemSal.Channel
  And tmpSal.SalesManID=tItemSal.SalesManID
  and tmpSal.Beat=tItemSal.Beat 
  And tmpSal.SchemeValue = tItemSal.SchemeValue
  And tmpSal.SCHEMEID = tItemSal.SCHEMEID
  and tmpSal.InvSchemeID = tItemSal.InvSchemeID
  and tmpSal.SplCatSchemeID = tItemSal.SplCatSchemeID 
  And tmpSal.InvSchemeValue = tItemSal.InvSchemeValue 
  And tmpSal.SplCatSchemeValue = tItemSal.SplCatSchemeValue 	
  and tmpsal.SchItem_Code=tItemSal.SchItem_Code
  and tmpSal.SplSchItem_Code=tItemSal.SplSchItem_Code
  and tmpSal.SplSchQty=tItemSal.SplSchQty*/


  /* Field RowsCount is req When an Invoice made more than once with same Data [Special Category Scheme]*/
  /*Update TmpSal Set tmpSal.SplCatRowsCount = tSplCatSal.SplCatRowsCount
  From #TempSale TmpSal,
  (Select ItemCode, SplCatSchemeValue, SplCatSchemeID,Count(ItemCode + SplCatSchemeValue + SplCatSchemeID ) as 'SplCatRowsCount'  
  From #TempSale WHERE (ISNULL(SPLCATSCHEMEID,'') <> '' ) Group By ItemCode, SplCatSchemeValue,SplCatSchemeID) tSplCatSal  
  Where tmpSal.ItemCode = tSplCatSal.ItemCode And  
  tmpSal.SplCatSchemeValue = tSplCatSal.SplCatSchemeValue And
  tmpSal.SplCatSchemeID	= tSplCatSal.SplCatSchemeID 

 Update TmpSal Set tmpSal.InvSchRowCount = tCatSal.InvSchRowCount
 From #TempSale TmpSal,
 (Select ItemCode, InvSchemeValue,InvSchemeID, Count(ItemCode + InvSchemeValue + InvSchemeID ) as 'InvSchRowCount'  
 From #TempSale WHERE (ISNULL(InvSchemeID,'') <> '' And  Cast(ISNULL(InvSchemeID,'') as nVarchar) <> '0' ) Group By ItemCode, InvSchemeValue,InvSchemeID) tCatSal  
 Where tmpSal.ItemCode = tCatSal.ItemCode And  
    tmpSal.InvSchemeValue = tCatSal.InvSchemeValue And
	tmpSal.InvSchemeID = tCatSal.InvSchemeID */


--  Select 1,* from  #TempSale    

  /* To remove the repeat entries for an Item with Item Based Free Item Scheme*/
  Select A.* into #TempSale2 From
  (Select SelCat, SelCatName, CatId, Channel, SalesManID, Beat, CustomerID, ItemCode, UOM, UOM1, UOM2, 
  Max(Serial) 'Serial', IsNull(Free,0) 'Free', IsNull(FreeValue,0) 'FreeValue', SchItem_Code, SchQty, SchValue, Sum(SumSchValue) 'SumSchValue',
  SplSchItem_code, SplSchQty, SplSchValue, Sum(SumSplSchValue) 'SumSplSchValue', IsNull(SplFlag,'') 'SplFlag', Sum(TotQty) 'TotQty', Sum(NetValue) 'NetValue',
  Sum(IsNull(DiscSalValue,0)) 'DiscSalValue', Sum(IsNull(SDiscSalValue,0))'SDiscSalValue', ClaimableInvSch, InvSchemeID, InvSchemeValue, ClaimableSch, SchemeID, SchemeValue, ClaimableSplSch, 
  SplCatSchemeID, SplCatSchemeValue, Sum(SNetValue) 'SNetValue', Sum(TNetValue) 'TNetValue', Sum(TDisc) 'TDisc', MUOM, SplCatRowsCount, ItemRowsCount,InvSchRowCount
  from #TempSale 
  Where Len(IsNull(SchItem_code,'')) > 0 
  Group By SelCat, SelCatName, CatId, Channel, SalesManID, Beat, CustomerID, ItemCode, UOM, UOM1, UOM2, 
  SchItem_Code, SchQty, SchValue,SplSchItem_code, SplSchQty, SplSchValue,  IsNull(SplFlag,''),
  ClaimableInvSch, InvSchemeID, InvSchemeValue, ClaimableSch, SchemeID, SchemeValue, ClaimableSplSch, 
  SplCatSchemeID, SplCatSchemeValue,MUOM, SplCatRowsCount, ItemRowsCount,InvSchRowCount, IsNull(Free,0), IsNull(FreeValue,0)
  Union All
  Select SelCat, SelCatName, CatId, Channel, SalesManID, Beat, CustomerID, ItemCode, UOM, UOM1, UOM2, 
  Serial, IsNull(Free,0) 'Free', IsNull(FreeValue,0) 'FreeValue', SchItem_Code, SchQty, SchValue, SumSchValue,
  SplSchItem_code, SplSchQty, SplSchValue, SumSplSchValue, IsNull(SplFlag,'') 'SplFlag', TotQty, NetValue,
  IsNull(DiscSalValue,0) 'DiscSalValue', IsNull(SDiscSalValue,0)'SDiscSalValue', ClaimableInvSch, InvSchemeID, InvSchemeValue, ClaimableSch, SchemeID, SchemeValue, ClaimableSplSch, 
  SplCatSchemeID, SplCatSchemeValue, SNetValue, TNetValue , TDisc , MUOM, SplCatRowsCount, ItemRowsCount,InvSchRowCount
  from #TempSale Where Len(IsNull(SchItem_code,'')) = 0) A

--  Select * from #TempSale2

  Set @SchList = ''  

  Declare SchNames Cursor For Select Distinct SchemeID,SchemeName from #TempAllSchemes  
  Open SchNames  
  Fetch From SchNames Into @SchID,@SchName  
  While @@Fetch_status = 0  
  Begin  
   Set @SchList = @SchList + ', [' + @SchName + ']'  
   Set @SqlStat = 'Alter Table #TempSale2 Add [' + @SchName + '] Decimal(18,6)'  
   Exec Sp_sqlExec @SqlStat  
   Set @SqlStat = 'Update #TempSale2 Set [' + @SchName + '] =   
            (Select dbo.merp_fn_Get_CSValue(IsNull(InvSchemeID,''''),IsNull(InvSchemeValue,''''),'+Cast(@SchID as nVarChar)+',IsNull(ItemRowsCount,'''')))   
            +  
            (Select dbo.merp_fn_Get_CSValue(IsNull(SchemeID,''''),IsNull(SchemeValue,''''),'+Cast(@SchID as nVarChar)+',IsNull(ItemRowsCount,'''')))   
            +  
            (Select dbo.merp_fn_Get_CSValue(IsNull(SchemeID,''''),IsNull(SchValue,''''),'+Cast(@SchID as nVarChar)+',IsNull(ItemRowsCount,'''')))   
            +  
            (Select dbo.merp_fn_Get_CSValue(IsNull(SplCatSchemeID,''''),IsNull(SplCatSchemeValue,''''),'+Cast(@SchID as nVarChar)+',IsNull(ItemRowsCount,'''')))  
            +  
            (Select dbo.merp_fn_Get_CSValue(IsNull(SplCatSchemeID,''''),IsNull(SplSchValue,''''),'+Cast(@SchID as nVarChar)+',IsNull(ItemRowsCount,'''')))'  

   print @SqlStat
   Exec Sp_sqlExec @SqlStat  
   Fetch Next From SchNames Into @SchID,@SchName  
  End  
  
  Close SchNames  
  DeAllocate SchNames  
 End  

--  Select * from #TempAllSchemes   
-- Select * from  #TempSale  
--select 2, * from  #TempSale2

Declare @GrpCode Int  
Declare @GrpCustCode nVarChar(30)  
Declare @UOMS int  
Declare @UOMList nVarChar(2000)  
  
If @ReportLevel = 'Channel Wise'  
 Begin  
  Declare MUomCursor Cursor For Select Channel from #TempSale2 Group By Channel  
  Open MUomCursor   
  Fetch from MUomCursor Into @GrpCode  
  While @@Fetch_Status = 0   
  Begin  
    Set @UOMList = ''  
    If @UOM = 'UOM2'  
     Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where Channel = @GrpCode  
    Else IF @UOM = 'UOM1'  
     Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where Channel = @GrpCode  
    Else  
     Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where Channel = @GrpCode  
    Open Uoms  
    Fetch from Uoms Into @UOMS  
    While @@Fetch_Status = 0  
    Begin  
     If @UOMList = ''  
      Set @UOMList = (Select Description from UOM Where UOM = @UOMS)  
     Else  
      Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)  
     Fetch Next from Uoms Into @UOMS  
    End  
    Close Uoms  
    Deallocate Uoms  
    Update #TempSale2 Set MUOM = @UOMList where Channel = @GrpCode  
   Fetch Next from MUomCursor Into @GrpCode  
  End  
  Close MUomCursor   
  Deallocate MUomCursor   
 End  
Else If @ReportLevel = 'DS wise'  
 Begin  
  Declare MUomCursor Cursor For Select SalesManID from #TempSale2 Group By SalesManID  
  Open MUomCursor   
  Fetch from MUomCursor Into @GrpCode  
  While @@Fetch_Status = 0   
  Begin  
    Set @UOMList = ''  
    If @UOM = 'UOM2'  
     Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where SalesManID = @GrpCode  
    Else IF @UOM = 'UOM1'  
     Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where SalesManID = @GrpCode  
    Else  
     Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where SalesManID = @GrpCode  
    Open Uoms  
    Fetch from Uoms Into @UOMS  
    While @@Fetch_Status = 0  
    Begin  
     If @UOMList = ''  
      Set @UOMList = (Select Description from UOM Where UOM = @UOMS)  
     Else  
      Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)  
     Fetch Next from Uoms Into @UOMS  
    End  
    Close Uoms  
    Deallocate Uoms  
    Update #TempSale2 Set MUOM = @UOMList where SalesManID = @GrpCode  
   Fetch Next from MUomCursor Into @GrpCode  
  End  
  Close MUomCursor   
  Deallocate MUomCursor   
 End  
Else If @ReportLevel = 'Beat wise'  
 Begin  
  Declare MUomCursor Cursor For Select Beat from #TempSale2 Group By Beat  
  Open MUomCursor   
  Fetch from MUomCursor Into @GrpCode  
  While @@Fetch_Status = 0   
  Begin  
    Set @UOMList = ''  
    If @UOM = 'UOM2'  
     Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where Beat = @GrpCode  
    Else IF @UOM = 'UOM1'  
     Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where Beat = @GrpCode  
    Else  
     Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where Beat = @GrpCode  
    Open Uoms  
    Fetch from Uoms Into @UOMS  
    While @@Fetch_Status = 0  
    Begin  
     If @UOMList = ''  
      Set @UOMList = (Select Description from UOM Where UOM = @UOMS)  
     Else  
      Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)  
     Fetch Next from Uoms Into @UOMS  
    End  
    Close Uoms  
    Deallocate Uoms  
    Update #TempSale2 Set MUOM = @UOMList where Beat = @GrpCode  
   Fetch Next from MUomCursor Into @GrpCode  
  End  
  Close MUomCursor   
  Deallocate MUomCursor   
 End  
Else If @ReportLevel = 'Customer wise'  
 Begin  
  Declare MUomCursor Cursor For Select CustomerID from #TempSale2 Group By CustomerID  
  Open MUomCursor   
  Fetch from MUomCursor Into @GrpCustCode  
  While @@Fetch_Status = 0   
  Begin  
    Set @UOMList = ''  
    If @UOM = 'UOM2'  
     Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where CustomerID = @GrpCustCode  
    Else IF @UOM = 'UOM1'  
     Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where CustomerID = @GrpCustCode  
    Else  
     Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where CustomerID = @GrpCustCode  
    Open Uoms  
    Fetch from Uoms Into @UOMS  
    While @@Fetch_Status = 0  
    Begin  
     If @UOMList = ''  
      Set @UOMList = (Select Description from UOM Where UOM = @UOMS)  
     Else  
      Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)  
     Fetch Next from Uoms Into @UOMS  
    End  
    Close Uoms  
    Deallocate Uoms  
    Update #TempSale2 Set MUOM = @UOMList where CustomerID = @GrpCustCode  
   Fetch Next from MUomCursor Into @GrpCustCode  
  End  
  Close MUomCursor   
  Deallocate MUomCursor   
 End  
Else --'Category Wise'  
 Begin  
  Declare MUomCursor Cursor For Select SelCat from #TempSale2 Group By SelCat  
  Open MUomCursor   
  Fetch from MUomCursor Into @GrpCode  
  While @@Fetch_Status = 0   
  Begin  
    Set @UOMList = ''  
    If @UOM = 'UOM2'  
     Declare Uoms Cursor for Select Distinct UOM2 from #TempSale2 where SelCat = @GrpCode  
    Else IF @UOM = 'UOM1'  
     Declare Uoms Cursor for Select Distinct UOM1 from #TempSale2 where SelCat = @GrpCode  
    Else  
     Declare Uoms Cursor for Select Distinct UOM from #TempSale2 where SelCat = @GrpCode  
    Open Uoms  
    Fetch from Uoms Into @UOMS  
    While @@Fetch_Status = 0  
    Begin  
     If @UOMList = ''  
      Set @UOMList = (Select Description from UOM Where UOM = @UOMS)  
     Else  
      Set @UOMList = @UOMList + '*' + (Select Description from UOM Where UOM = @UOMS)  
     Fetch Next from Uoms Into @UOMS  
    End  
    Close Uoms  
    Deallocate Uoms  
    Update #TempSale2 Set MUOM = @UOMList where SelCat = @GrpCode  
   Fetch Next from MUomCursor Into @GrpCode  
  End  
  Close MUomCursor   
  Deallocate MUomCursor   
 End  
 Update #TempSale2 Set DiscSalValue =   
--   Case When (Case When IsNull(SNetValue,0) > IsNull(PNetValue,0) Then IsNull(SNetValue,0) Else IsNull(PNetValue,0) End) >  
--   (Case When IsNull(ANetValue,0) > IsNull(TNetValue,0) Then IsNull(ANetValue,0) Else IsNull(TNetValue,0) End) Then  
--   (Case When IsNull(SNetValue,0) > IsNull(PNetValue,0) Then IsNull(SNetValue,0) Else IsNull(PNetValue,0) End) Else  
--   (Case When IsNull(ANetValue,0) > IsNull(TNetValue,0) Then IsNull(ANetValue,0) Else IsNull(TNetValue,0) End) End  
	Case When IsNull(SNetValue,0) > IsNull(TNetValue,0) Then IsNull(SNetValue,0) Else IsNull(TNetValue,0) End


Create Table #TempPreResult    
(  
 Code int,  
 GrpBy nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 UOMs nVarChar(2000),  
 TotQty decimal(18,6),  
 Free Decimal(18,6),  
 FreeValue Decimal(18,6),  
 TotSalVal Decimal(18,6),  
 DiscSalVal Decimal(18,6),  
 SDiscSalVal Decimal(18,6),  
 SchSalVal Decimal(18,6),  
 PSalVal Decimal(18,6),  
 PDisc Decimal(18,6),  
 ASalVal Decimal(18,6),  
 ADisc Decimal(18,6),  
 TSalVal Decimal(18,6),  
 TDisc Decimal(18,6),  
 TotDisc Decimal(18,6),  
 TotSchDisc Decimal(18,6)  
)  
  
If @ReportLevel = 'Channel Wise'  
 Insert into #TempPreResult   
 (Code, GrpBy, UOMs, TotQty, Free, FreeValue,   
 TotSalVal, DiscSalVal,SDiscSalVal, SchSalVal ,   
 --PSalVal , PDisc, ASalVal, ADisc, 
 TSalVal, TDisc, TotDisc)  
 Select Channel, Max(CC.ChannelDesc),  
 Max(MUOM),  
 Sum(IsNull(TotQty,0)),  
 Sum(IsNull(Free,0)),  
 Sum(IsNull(FreeValue,0)),  
 Sum(IsNull(NetValue,0)),  
 Sum(IsNull(DiscSalValue,0)),  
 Sum(IsNull(SDiscSalValue,0)),  
 Sum(IsNull(SNetValue,0)),  
 --Sum(IsNull(PNetValue,0)),  
 --Sum(IsNull(PDisc,0)),  
 --Sum(IsNull(ANetValue,0)),  
 --Sum(IsNull(ADisc,0)),  
 Sum(IsNull(TNetValue,0)),  
 Sum(IsNull(TDisc,0)),  
 --Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))  
 Sum(IsNull(TDisc,0))  
 from #TempSale2 TS,Customer_Channel CC  
 Where TS.Channel = CC.ChannelType  
 Group by Channel  
  
Else If @ReportLevel = 'DS wise'  
 Insert into #TempPreResult   
 (Code, GrpBy, UOMs, TotQty, Free, FreeValue,   
 TotSalVal,DiscSalVal, SDiscSalVal, SchSalVal ,   
 --PSalVal , PDisc, ASalVal, ADisc, 
 TSalVal, TDisc, TotDisc)  
 Select TS.SalesManID,Max(SM.SalesMan_Name),  
 Max(MUOM),  
 Sum(IsNull(TotQty,0)),  
 Sum(IsNull(Free,0)),  
 Sum(IsNull(FreeValue,0)),  
 Sum(IsNull(NetValue,0)),  
 Sum(IsNull(DiscSalValue,0)),  
 Sum(IsNull(sDiscSalValue,0)),  
 Sum(IsNull(SNetValue,0)),  
 --Sum(IsNull(PNetValue,0)),  
 --Sum(IsNull(PDisc,0)),  
 --Sum(IsNull(ANetValue,0)),  
 --Sum(IsNull(ADisc,0)),  
 Sum(IsNull(TNetValue,0)),  
 Sum(IsNull(TDisc,0)),  
 --Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))  
 Sum(IsNull(TDisc,0))  
 from #TempSale2 TS,SalesMan SM  
 Where TS.SalesManID = SM.SalesManID  
 Group by TS.SalesManID  
  
Else If @ReportLevel = 'Beat wise'  
 Insert into #TempPreResult   
 (Code, GrpBy, UOMs, TotQty, Free, FreeValue,   
 TotSalVal,DiscSalVal, sDiscSalVal, SchSalVal ,   
 --PSalVal , PDisc, ASalVal, ADisc, 
 TSalVal, TDisc, TotDisc)  
 Select Beat,Max(B.Description),  
 Max(MUOM),  
 Sum(IsNull(TotQty,0)),  
 Sum(IsNull(Free,0)),  
 Sum(IsNull(FreeValue,0)),  
 Sum(IsNull(NetValue,0)),  
 Sum(IsNull(DiscSalValue,0)),  
 Sum(IsNull(sDiscSalValue,0)),  
 Sum(IsNull(SNetValue,0)),  
 --Sum(IsNull(PNetValue,0)),  
 --Sum(IsNull(PDisc,0)),  
 --Sum(IsNull(ANetValue,0)),  
 --Sum(IsNull(ADisc,0)),  
 Sum(IsNull(TNetValue,0)),  
 Sum(IsNull(TDisc,0)),  
 --Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))  
 Sum(IsNull(TDisc,0))  
 from #TempSale2 TS,Beat B  
 Where Beat = B.BeatID  
 Group by Beat  
  
Else If @ReportLevel = 'Customer wise'  
 Insert into #TempPreResult   
 (Code, GrpBy, UOMs, TotQty, Free, FreeValue,   
 TotSalVal,DiscSalVal, sDiscSalVal, SchSalVal ,   
 --PSalVal , PDisc, ASalVal, ADisc, 
 TSalVal, TDisc, TotDisc)  
 Select 1,CustomerID,  
 Max(MUOM),  
 Sum(IsNull(TotQty,0)),  
 Sum(IsNull(Free,0)),  
 Sum(IsNull(FreeValue,0)),  
 Sum(IsNull(NetValue,0)),  
 Sum(IsNull(DiscSalValue,0)),  
 Sum(IsNull(sDiscSalValue,0)),  
 Sum(IsNull(SNetValue,0)),  
 --Sum(IsNull(PNetValue,0)),  
 --Sum(IsNull(PDisc,0)),  
 --Sum(IsNull(ANetValue,0)),  
 --Sum(IsNull(ADisc,0)),  
 Sum(IsNull(TNetValue,0)),  
 Sum(IsNull(TDisc,0)),  
 --Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))  
 Sum(IsNull(TDisc,0))  
 from #TempSale2 TS  
 Group by CustomerID  
  
Else --'Category Wise'  
 Insert into #TempPreResult   
 (Code, GrpBy, UOMs, TotQty, Free, FreeValue,   
 TotSalVal,DiscSalVal, sDiscSalVal, SchSalVal ,   
 --PSalVal , PDisc, ASalVal, ADisc, 
 TSalVal, TDisc, TotDisc)  
 Select SelCat, Max(SelCatName),  
 Max(MUOM),  
 Sum(IsNull(TotQty,0)),  
 Sum(IsNull(Free,0)),  
 Sum(IsNull(FreeValue,0)),  
 Sum(IsNull(NetValue,0)),  
 Sum(IsNull(DiscSalValue,0)),  
 Sum(IsNull(sDiscSalValue,0)),  
 Sum(IsNull(SNetValue,0)),  
 --Sum(IsNull(PNetValue,0)),  
 --Sum(IsNull(PDisc,0)),  
 --Sum(IsNull(ANetValue,0)),  
 --Sum(IsNull(ADisc,0)),  
 Sum(IsNull(TNetValue,0)),  
 Sum(IsNull(TDisc,0)),  
 --Sum(IsNull(PDisc,0)+IsNull(ADisc,0)+IsNull(TDisc,0))  
 Sum(IsNull(TDisc,0))  
 from #TempSale2 TS  
 Group by SelCat  
  
-- Select * from #TempPreResult   
  
if @DiscType <> 'Only Free Item'  
 Begin  
  Declare SchNames Cursor For Select Distinct SchemeID,SchemeName from #TempAllSchemes  
  Open SchNames  
  Fetch From SchNames Into @SchID,@SchName  
  While @@Fetch_status = 0  
  Begin  
   Set @SqlStat = 'Alter Table #TempPreResult Add [' + @SchName + '] Decimal(18,6)'  
   Exec Sp_sqlExec @SqlStat  
  
   If @ReportLevel = 'Channel Wise'  
     Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] =   
    (Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale2 Where Channel =  #TempPreResult.Code Group BY Channel),  
     TotSchDisc = IsNull(TotSchDisc,0) +  
    (Select Sum(IsNull(['+ @SchName +'],0))   
    From #TempSale2 Where Channel =  #TempPreResult.Code Group BY Channel)'  
   Else If @ReportLevel = 'DS wise'  
     Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] =   
    (Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale2 Where #TempSale2.SalesManID =  #TempPreResult.Code Group BY #TempSale2.SalesManID),  
     TotSchDisc = IsNull(TotSchDisc,0) +  
    (Select Sum(IsNull(['+ @SchName +'],0))   
    From #TempSale2 Where #TempSale2.SalesManID =  #TempPreResult.Code Group BY #TempSale2.SalesManID)'  
   Else If @ReportLevel = 'Beat wise'  
     Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] =   
    (Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale2 Where Beat =  #TempPreResult.Code Group BY Beat),  
     TotSchDisc = IsNull(TotSchDisc,0) +  
    (Select Sum(IsNull(['+ @SchName +'],0))   
    From #TempSale2 Where Beat =  #TempPreResult.Code Group BY Beat)'  
   Else If @ReportLevel = 'Customer wise'  
     Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] =   
    (Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale2 Where CustomerID =  #TempPreResult.GrpBy Group BY CustomerID),  
     TotSchDisc = IsNull(TotSchDisc,0) +  
    (Select Sum(IsNull(['+ @SchName +'],0))   
    From #TempSale2 Where CustomerID =  #TempPreResult.GrpBy Group BY CustomerID)'  
   Else --'Category Wise'  
     Set @SqlStat = 'Update #TempPreResult Set [' + @SchName + '] =   
    (Select Sum(IsNull(['+ @SchName +'],0)) From #TempSale2 Where SelCat = Code Group BY SelCat),  
     TotSchDisc = IsNull(TotSchDisc,0) +  
    (Select Sum(IsNull(['+ @SchName +'],0))   
    From #TempSale2 Where SelCat = Code Group BY SelCat)'  
--                Print @SqlStat  
    Exec Sp_sqlExec @SqlStat  
    Fetch Next From SchNames Into @SchID,@SchName  
  End  
  
  Close SchNames  
  DeAllocate SchNames  
End  
  
-- Select * from #TempPreResult   
  
Set @SqlStat = ''  
  
If @DiscType = 'Scheme'  
 Begin  
  If @ReportLevel = 'Channel Wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'  
  Else If @ReportLevel = 'DS wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'  
  Else If @ReportLevel = 'Beat wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'  
  Else If @ReportLevel = 'Customer wise'  
   Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'  
  Else --'Category Wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'  
   
  Set @SqlStat = @SqlStat +   
   '"UOM" = UOMs,  
   "Total Volume" = TotQty,  
   "Total Sales Value" = TotSalVal,  
   "Discountable Sales Value" = SchSalVal' + @SchList + ',  
   "Total Value" = TotSchDisc From #TempPreResult Where SchSalVal <>0'  
 End  
--Else If @DiscType = 'Product Discount'  
-- Begin  
--  If @ReportLevel = 'Channel Wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'   
--  Else If @ReportLevel = 'DS wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'   
--  Else If @ReportLevel = 'Beat wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'   
--  Else If @ReportLevel = 'Customer wise'  
--   Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'    
--  Else --'Category Wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'  
--   
--  Set @SqlStat = @SqlStat +   
----   '"UOM" = IsNull((Select Description from UOM Where UOM = UOMID),''*''),  
--   '"UOM" = UOMs,  
--   "Total Volume" = TotQty,  
--   "Total Sales Value" = TotSalVal,  
--   "Discountable Sales Value" = PSalVal,  
--   "Product Discount" = PDisc From #TempPreResult Where PSalVal <> 0'  
-- End  
Else If @DiscType = 'Trade Discount'  --'Addl. Discount'  
 Begin  
  If @ReportLevel = 'Channel Wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'  
  Else If @ReportLevel = 'DS wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'  
  Else If @ReportLevel = 'Beat wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'  
  Else If @ReportLevel = 'Customer wise'  
   Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'  
  Else --'Category Wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'  
   
  Set @SqlStat = @SqlStat +  
   '"UOM" = UOMs,  
   "Total Volume" = TotQty,  
   "Total Sales Value" = TotSalVal,  
   "Discountable Sales Value" = TSalVal,  
   "Trade Discount" = TDisc From #TempPreResult Where TSalVal <> 0'  
 End  
  
--Else If @DiscType = 'Trade Discount'  
-- Begin  
--  If @ReportLevel = 'Channel Wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'  
--  Else If @ReportLevel = 'DS wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'  
--  Else If @ReportLevel = 'Beat wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'  
--  Else If @ReportLevel = 'Customer wise'  
--   Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'  
--  Else --'Category Wise'  
--   Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'  
--   
--  Set @SqlStat = @SqlStat +   
--   '"UOM" = UOMs,  
--   "Total Volume" = TotQty,  
--   "Total Sales Value" = TotSalVal,  
--   "Discountable Sales Value" = TSalVal,  
--   "Trade Discount" = TDisc From #TempPreResult Where TSalVal <> 0'  
-- End  
Else if @DiscType = 'Only Free Item'  
 Begin  
  If @ReportLevel = 'Channel Wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'  
  Else If @ReportLevel = 'DS wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'  
  Else If @ReportLevel = 'Beat wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'  
  Else If @ReportLevel = 'Customer wise'  
   Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'  
  Else --'Category Wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'  
   
  Set @SqlStat = @SqlStat +  
   '"UOM" = UOMs,  
   "Free Item Volume" = Free ,   
   "Free Item Value" = FreeValue From #TempPreResult Where Free <> 0'  
 End  
Else --'All without Free Item'  
 Begin  
  If @ReportLevel = 'Channel Wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Channel Name" = GrpBy,'  
  Else If @ReportLevel = 'DS wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"DS Name" = GrpBy,'  
  Else If @ReportLevel = 'Beat wise'  
   Set @SqlStat = @SqlStat + 'Select Code,"Beat Name" = GrpBy,'  
  Else If @ReportLevel = 'Customer wise'  
   Set @SqlStat = @SqlStat + 'Select GrpBy,"Customer Name" = (Select Company_Name from Customer Where CustomerID = GrpBy),'  
  Else --'Category Wise'  
  Set @SqlStat = @SqlStat + 'Select Code,"Category Name" = GrpBy,'  
   
 If @Claimable ='Yes'  
   Set @SqlStat = @SqlStat +  
    '"UOM" = UOMs,  
    "Total Volume" = TotQty,  
    "Total Sales Value" = TotSalVal,  
    "Discountable Sales Value" = SchSalVal ' + @SchList + ',  
    "Total Value" = IsNull(TotSchDisc,0) From #TempPreResult Where SchSalVal <> 0'  
 Else  
   Set @SqlStat = @SqlStat +  
    '"UOM" = UOMs,  
    "Total Volume" = TotQty,  
    "Total Sales Value" = TotSalVal,  
    "Discountable Sales Value" = DiscSalVal ' + @SchList + ',  
    "Trade Discount" = TDisc,  
    "Total Value" = IsNull(TotDisc,0)+IsNull(TotSchDisc,0) From #TempPreResult Where DiscSalVal <> 0'  
--    '"UOM" = UOMs,  
--    "Total Volume" = TotQty,  
--    "Total Sales Value" = TotSalVal,  
--    "Discountable Sales Value" = DiscSalVal ' + @SchList + ',  
--	  "Product Discount" = PDisc,  
--    "Addl Discount" = ADisc,  
--    "Trade Discount" = TDisc,  
--    "Total Value" = IsNull(TotDisc,0)+IsNull(TotSchDisc,0) From #TempPreResult Where DiscSalVal <> 0'  
 End  

Exec Sp_sqlExec @SqlStat  

Drop Table #TempCategory  
Drop Table #TempSelectedCats  
Drop Table #TempSelCatsLeaf  
Drop Table #TempChannels  
Drop Table #TempSalesMans  
Drop Table #TempBeats  
Drop Table #TempCust  
Drop Table #TempSale  
Drop Table #TempSale2  
Drop Table #TempSchemes   
Drop Table #TempAllSchemes   
Drop Table #TempPreResult  
  
