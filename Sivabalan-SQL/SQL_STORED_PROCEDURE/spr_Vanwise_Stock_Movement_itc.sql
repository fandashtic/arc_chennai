Create Procedure spr_Vanwise_Stock_Movement_itc
					(@Van nVarChar(2550), 
					 @Salesman nVarChar(2550), 
					 @UOM nVarChar(50), 
				         @ProHier nVarChar(255),  
					 @Category nVarchar(2550),  
                                         @ToDate DateTime)  
As
Declare @Delimeter as Char(1)    
Declare @VanP nVarchar(10)

Set @Delimeter=Char(15)    

Select @VanP = Prefix FROM VoucherPrefix WHERE TranID = N'VAN LOADING STATEMENT'

Create table #tmpVan(Vans nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpSal(Salesman nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tempCategory (CategoryID Int, Status Int)  

Exec GetLeafCategories @ProHier, @Category
Select Distinct CategoryID InTo #temp From #tempCategory  
  
If @Van = '%'     
   Insert InTo #tmpVan Select Van From Van
Else    
   Insert InTo #tmpVan Select * From dbo.sp_SplitIn2Rows(@Van, @Delimeter)    

If @Salesman = '%'
   Insert InTo #tmpSal Select Salesman_Name from Salesman    
Else    
   Insert into #tmpSal select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter)    

-- select Vans from #tmpvan

Select vs.DocSerial, "Godown" = sa.Salesman_Name, "Date" = vs.LoadingDate, 
"Van Statement No" = @Vanp + Cast(vs.DocumentID As nVarChar), "Van Number" = v.Van_Number 
From Salesman sa, VanstatementAbstract vs, Van v, VanstatementDetail vd, Items its
Where vs.DocSerial = vd.DocSerial And sa.SalesmanID = vs.SalesmanID And vs.VanID = v.Van And 
its.Product_Code = vd.Product_Code And v.Van In (Select Vans From #tmpVan) And
sa.Salesman_Name In (Select Salesman From #tmpSal) And 
vs.LoadingDate <= @ToDate And vs.Status & 192 = 0 And 
its.Categoryid In (Select CategoryID From #temp)
Group By sa.Salesman_Name, vs.LoadingDate, vs.DocumentID, v.Van_Number, vs.DocSerial

Drop Table #tmpVan
Drop Table #tmpSal
Drop Table #temp 
Drop Table #tempCategory  

