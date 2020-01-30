
CREATE Procedure sp_Validate_ComparisonParameters_Pidilite
(    
@RefFromDate DateTime,
@RefToDate DateTime,
@ComFromDate DateTime,   
@ComToDate DateTime
) 
As

Declare @ComparisonDB nvarchar(500)
Declare @CYOperatingYear int
Declare @RYOperatingYear int
Declare @RegOwner nvarchar(200)
Declare @OpeningDate datetime
Declare @ClosingDate datetime
Declare @Status nvarchar(200)
Declare @Month int

		-- Basic Date Validations From Dates should be Lesser than to Dates
		-- Financial Year Report (Month < 12)

    If (@RefFromDate > @RefToDate) or (@ComFromDate > @ComToDate) 
    or (Datediff(month,@RefFromDate,@RefTodate) > 11) or (Datediff(month,@ComFromDate,@ComToDate) > 11) 
    Begin
 				Set @Status = N'Invalid Date Range' 
 				Goto FaultTolerance
    End

	  If (@ComFromDate > @RefFromDate) or (@ComToDate > @RefToDate)
				Begin
						Set @Status = N'Comparison dates should be lesser than Reference dates'
						Goto FaultTolerance
				End

		-- Forming the Database Name                        
		Set @RegOwner = (select RegisteredOwner from setup)
		Set @Month = (select fiscalyear from Setup)
	
		Set @CYOperatingYear = Year(@ComFromDate)
  	If Datepart(dy,@ComFromDate) < DatePart(dy,@OpeningDate)
			Set @CYOperatingYear = @CYOperatingYear - 1    
			
		Set @ComparisonDB = N'Minerva_' + @RegOwner + N'_' + Cast(@CYOperatingYear as nVarchar)
	
		-- Finding the Opening and Closing Dates for the Current Financial Year	
		Set @RYOperatingYear = (select substring(OperatingYear,1,4) from setup)
		Set @OpeningDate = '1' + '/' + cast(@Month as varchar) + '/' + cast(@RYOperatingYear as varchar)
		Set @ClosingDate = dbo.Makedayend(dateadd(year,1,@OpeningDate-1))

		--If Close Period process has not been done Closing Date to be Incremented accordingly
		If datediff(month,@OpeningDate,Getdate()) > 11 
			Set @ClosingDate = dateadd(Year,datediff(Year,@OpeningDate,Getdate()),@ClosingDate)
			
		-- Checking whether the Reference Dates are within the Reference Financial Year (Current Year DB)
		If Not (@RefFromDate >= @OpeningDate and @RefToDate <= @ClosingDate)
		Begin
    	Set @Status = N'Reference Dates are not within Financial Year' + cast(@ClosingDate as nvarchar) 
    	Goto FaultTolerance
		End

		-- If Close Period Process not done and the comparison period falls within the reference Year
		-- Then DataBase Name should be the name of the reference Year

		If (@CYOperatingYear >= @RYOperatingYear) and Datediff(month,@OpeningDate,Getdate()) > 11 
		Begin
			Set @CYOperatingYear = @RYOperatingYear
			Set @ComparisonDB = 'Minerva_' + @RegOwner + N'_' + Cast(@CYOperatingYear as nVarchar)
		End
		Else 
			Set @ClosingDate = dbo.Makedayend(dateadd(year,1,@OpeningDate-1))

		If Not(@ComFromDate >= Dateadd(Year,(@CYOperatingYear - @RYOperatingYear),@OpeningDate) and 
           @ComToDate <= Dateadd(Year,(@CYOperatingYear -  @RYOperatingYear),@ClosingDate))
	 	Begin
   		Set @Status = N'Comparison Dates are not within the Comparison Financial Year'
    	Goto FaultTolerance
	 	End

		-- Checking whether the Comparison Database exists in the system
		If exists(select name from master..sysdatabases where [Name] = @ComparisonDB)  
   	Begin
	    Insert into #tmpValidations(Flag,Status) Values (1,@ComparisonDB)
	    UpDate #tmpValidations Set RYTransDate = @OpeningDate
	    UpDate #tmpValidations Set CYTransDate = Dateadd(Year,(@CYOperatingYear - @RYOperatingYear),@OpeningDate)
	    Return
	  End
		Else
 			Set @Status = N'Database ' + @ComparisonDB + N' For the Financial Year ' + Cast((@CYOperatingYear) as varchar) + N'-' + Cast((@CYOperatingYear + 1) as varchar) + N' does not exist'    	
		
	FaultTolerance:
	Insert into #tmpValidations(Flag,Status) Values (0,@Status)

