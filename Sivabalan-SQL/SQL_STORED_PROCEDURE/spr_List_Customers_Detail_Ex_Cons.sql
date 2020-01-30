CREATE Procedure spr_List_Customers_Detail_Ex_Cons
(
	@BeatID NVarChar(15),
	@FROMDATE DateTime, 
	@TODATE DateTime
)    
AS    
		Declare @FromDateBh DateTime
		Declare @ToDateBh DateTime
	
	 Set @FromDateBh = dbo.StripDateFromTime(@FromDate)      
	 Set @ToDateBh = dbo.StripDateFromTime(@ToDate)  

		Declare		@CIDRpt As NVarChar(50)
		Declare		@CIDSetUp As NVarChar(50)
		Select @CIDSetUp=RegisteredOwner From Setup 
		Select @CIDRpt=Right(@BeatID,Len(@CIDSetUp))

		If @CIDRpt <>@CIDSetUp
			Begin
				Select
							RDR.Field1,"Distributor Code"=CompanyId,"CustomerID" =RDR.Field1,
						 "Customer Name" =RDR.Field2,"Channel Type" = RDR.Field3 ,"Contact Person"= RDR.Field4,
					 	"Salesman" =RDR.Field5,"Forum Code" = RDR.Field6
				From
					ReportDetailReceived RDR,ReportAbstractReceived RAR,Reports
				Where
					RDR.RecordID =@BeatID	
					And	RDR.RecordID=RAR.RecordID 
					And RAR.ReportId=Reports.ReportId 
					And RDR.Field1 <> N'CustomerID' And RDR.Field1 <> N'SubTotal:' And RDR.Field1 <> N'GrandTotal:'  
			End
		Else
			Begin
				Declare @BTID As Int
				Select @BTID=Left(Cast(@BeatID As NVarChar),Len(@BeatID)-Len(@CIDSetUp))
				IF @BTID = 0
					BEGIN    
					 Select 
							CustomerID,"Distributor Code"=@CIDSetUp,"CustomerID" = CustomerID, "Customer Name" = Company_Name,     
					 	"Channel Type" = Customer_Channel.ChannelDesc, "Contact Person"=ContactPerson,    
					 	"Salesman" =(
									Select 
										salesman_name 
									From 
										salesman, Beat_Salesman    
								 Where 
										Salesman.SalesmanID = Beat_Salesman.SalesmanID And    
					 				Beat_Salesman.BeatID = @BTID And    
									 Beat_Salesman.CustomerID = Customer.CustomerID),    
					 	"Forum Code" = AlternateCode    
					 From 
							Customer, Customer_Channel 
						Where 
							CustomerID Not In (Select CustomerID From Beat_Salesman) 
							And dbo.StripDateFromTime(CreationDate) = @FromDateBh   
							And	dbo.StripDateFromTime(CreationDate) = @ToDateBh      
						 And Customer.ChannelType = Customer_Channel.ChannelType    
					END    
				ELSE    
					BEGIN    
					 Select 
							CustomerID,"Distributor Code"=@CIDSetUp,"CustomerID" = CustomerID, "Customer Name" = Company_Name,     
					 	"Channel Type" = Customer_Channel.ChannelDesc, "Contact Person"=ContactPerson,     
					 	"Salesman" =
								(Select 
										Salesman_name 
									From 
										salesman, Beat_Salesman    
					 			Where 
										Salesman.SalesmanID = Beat_Salesman.SalesmanID And    
									 Beat_Salesman.BeatID = @BTID And    
					 				Beat_Salesman.CustomerID = Customer.CustomerID),    
					 	"Forum Code" = AlternateCode    
					 From 
							Customer, Customer_Channel Where CustomerID In (Select CustomerID From Beat_Salesman Where BeatID = @BTID) 
							And dbo.StripDateFromTime(CreationDate) = @FROMDATEBH 
 						And  dbo.StripDateFromTime(CreationDate) = @TODATEBH   
	 				 And Customer.ChannelType = Customer_Channel.ChannelType    
					END
			End

