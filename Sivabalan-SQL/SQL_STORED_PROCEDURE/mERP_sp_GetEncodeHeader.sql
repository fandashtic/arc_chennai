Create Procedure mERP_sp_GetEncodeHeader(@ReportID Int)
As
Begin
If @ReportID = 900
Select '<EncodedHeader _1="WD_Code" _2="WD_Dest_Code" _3="From_Date" _4="To_Date" _5="Customer_ID" _6="RCS_ID" _7="System_SKU_Code" _8="Sales" _9="Sales_Return_Damages" _10="Value" _11="Active_in_RCS" _12="Sales_With_GV" _13="Value_With_GV" _14="Customer_Type" _15="Channel_Type" _16="Outlet_Type" _17="Loyalty_Program" _18="Base_GOI_Market_ID" _19="Base_GOI_Market_Name"'
If @ReportID = 975
Select '<EncodedHeader _1="WDCode" _2="WDDest" _3="From_Date" _4="To_Date" _5="DocID" _6="DocNo" _7="DocType" _8="Doc_Ref" _9="Doc_Date" _10="Doc_Status" _11="DeliveryDate" _12="OrderReference" _13="Payment_Mode" _14="CustomerID" _15="CustomerName" _16="RCSID" _17="Customer_Address" _18="ChannelID" _19="ChannelName" _20="New_Channel_Type" _21="New_Outlet_Type" _22="New_Loyalty_Program" _23="BeatName" _24="DSID" _25="DSName" _26="DS_SubType" _27="Supervisor_ID" _28="Supervisor_Name" _29="Supervisor_Type" _30="CategoryGroup" _31="Transaction_Type" _32="GrossValue" _33="TotalDisc" _34="TotSchemeDisc" _35="TotTradeDisc" _36="TotalTax" _37="NetValue" _38="RoundOff" _39="AdjustedAmount" _40="AmountReceivable" _41="CreationDate" _42="InvRefNo" _43="OrderID" _44="OrderNo" _45="OrderRefNo" _46="OrderDate" _47="OrderType" _48="OrderGrossValue" _49="OrderNetValue" _50="Credit_Limit_Exceed" _51="GV_No" _52="GV_Amount" _53="GV_Adj.Val" _54="GV_Bal.Amt" _55="GenerationDateTime" _56="Base_GOI_Market_ID" _57="Base_GOI_Market_Name" _58="Reason" _59="OrgDocStatus" _60="StateType" _61="RegStatus" _62="Type" _63="ID" _64="SysSKUCode" _65="SKUName" _66="BatchCode" _67="BatchNumber" _68="ItemSeqNo" _69="BaseUOM" _70="BUOMQty" _71="Volume" _72="BillUOM" _73="BillQty" _74="OrderBaseUOM" _75="OrderBaseUOMQTY" _76="OrderUOM" _77="OrderQTY" _78="SalePrice" _79="SalesTax" _80="PurchaseTax" _81="GrossValue" _82="TotDiscValue" _83="TaxValue" _84="NetValue" _85="PTR" _86="PTS" _87="MRP" _88="FreeType" _89="RefItemSeqNo" _90="SchSeqNo" _91="Comp_ActivityCode" _92="Scheme_Desc" _93="Disc%" _94="DiscValue" _95="Scheme%" _96="SchemeValue" _97="ISCompany" _98="PurTaxVal" _99="PurTaxType" _100="TaxCode"'
IF @ReportID = 1008
Select '<EncodedHeader _1="WD_Code" _2="WD_Dest_Code" _3="From_Date" _4="To_Date" _5="Customer_ID" _6="Customer_Name" _7="Categories_Being_Handled" _8="Sub_Categories_being_Handled"'
IF @ReportID = 974
Select '<EncodedHeader _1="WDCode" _2="WDDest" _3="FromDate" _4="ToDate" _5="CustomerID" _6="CustomerName" _7="RCS_ID" _8="Active_In_RCS" _9="Beat_ID" _10="Beat" _11="DS_ID" _12="DSName" _13="DS_Type" _14="DS_SubType" _15="Handheld_DS" _16="Channel_Class" _17="Channel_ID" _18="Channel" _19="New_Channel_Type" _20="New_Outlet_Type" _21="New_Loyalty_Program" _22="Outstanding" _23="Total_Time_Spent_with_HH" _24="No._of_Days_with_HH" _25="Order_Taken" _26="Billing_Address" _27="Shipping_Address" _28="Merchandise" _29="DateTime_Of_Gen" _30="Active" _31="Base_GOI_Market_ID" _32="Base_GOI_Market_Name" _33="Latitude" _34="Longitude" _35="CreationTime" _36="MobileNo" _37="RegistrationStatus" _38="DSMobileNo" _39="Default_Beat" _40="GSTIN"'
IF @ReportID = 1151
Select '<EncodedHeader _1="WDCode" _2="WDDest" _3="From_Date" _4="To_Date" _5="Activity_Code" _6="Description" _7="Scheme_FromDate" _8="Scheme_ToDate" _9="Outlet_Code" _10="Outlet_Name" _11="Total_Points" _12="Total_Spent" _13="Redeemed_Points"'
IF @ReportID = 1117--mERP_spr_DSPerformance_Upload
Select '<EncodedHeader _1="WDCode" _2="WDDest" _3="From_Date" _4="To_Date" _5="DSID" _6="DSName" _7="DS_Type" _8="Performance_Metrics_Code" _9="Description" _10="Category_Group" _11="Parameter" _12="Overall_or_Focus" _13="Frequency" _14="Proposed_Target_Value" _15="Target" _16="Average_Till_Date" _17="Till_date_Actual" _18="Max_Points" _19="Till_Date_Points_Earned" _20="Last_Update_Date" _21="Generation_Date" _22="Last_Transaction_Date" _23="TargetType" _24="Product_Code" _25="Product_Name" _26="PMProductName" _27="LevelofProduct"'
IF @ReportID = 1318
Select '<EncodedHeader _1="WD_Code" _2="WD_Dest" _3="From_Date" _4="To_Date" _5="DOCID" _6="Date" _7="Type" _8="DSID" _9="DS_Name" _10="CustomerID" _11="Customer_Name" _12="ItemCode" _13="ItemName" _14="BatchNo" _15="UOM" _16="Quantity" _17="Value" _18="Reason"'
IF @ReportID = 1350
Select '<EncodedHeader _1="WD_Code" _2="WD_Dest" _3="From_Date" _4="To_Date" _5="Asset_No" _6="Asset_Type" _7="CustomerID" _8="CustomerName" _9="SalesmanID" _10="Status" _11="Creation_Time" _12="Download_Time"'

IF @ReportID = 1412 --Spr_QuotationMasterList_XML
Select '<EncodedHeader _1="WD_Code" _2="WD_Dest" _3="FromDate" _4="ToDate" _5="Quotation_Name" _6="Quotation_Date" _7="Valid_From_Date" _8="Valid_To_Date" _9="Type" _10="CustomerID" _11="Customer_Name" _12="Customer_Channel_Type" _13="Active" _14="Special_Tax" _15="Quotation_Type" _16="QuotationID" _17="Last_Modified_Date" _18="Item_Code" _19="Item_Name" _20="UOM" _21="Purchase_Price" _22="Sales_Price" _23="ECP" _24="Variance_On" _25="Variance_Percentage" _26="Rate_Quoted" _27="LST_Percentage" _28="Spl_Tax_LST" _29="QuotationID"'

IF @ReportID = 1423 --spr_CLOCRNote_Adjustment_UploadXML
Select '<EncodedHeader _1="WD_Code" _2="WD_Dest" _3="From_Date" _4="To_Date" _5="Type" _6="Month" _7="Ref_Number" _8="Customer_ID" _9="Customer_Name" _10="Amount" _11="Adjusted_Value" _12="Balance_Value" _13="CreditID" _14="Document_Type" _15="SL_NO" _16="Document_ID" _17="Document_Date" _18="Adjustment_Value" _19="CreditID"'

IF @ReportID = 1464 --mERP_spr_GGRR_Target_UploadXML
Select '<EncodedHeader _1="WD_Dest" _2="Month" _3="Customer_ID" _4="Customer_Name" _5="DS_ID" _6="DS_Name" _7="DS_Type" _8="Last_Day_Close_Date" _9="Product_Code" _10="Target" _11="Target_UOM" _12="Actual" _13="Points" _14="WinnerSKU_Flag"'

End
