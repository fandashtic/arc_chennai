CREATE Function fn_CanSaveCustomer(@ID int)      
Returns nvarchar(1)      
As      
Begin      
	Declare @Forumcode nvarchar(40)      
	Declare @Cusid nvarchar(30)      
	Declare @CusName nvarchar(256)      
	Declare @CanSaveCus nvarchar(1)      
	Declare @CountCus int      
	Declare @MemberShipCode nvarchar(100)   
	--Declare @UnqCustNameCnt as Int
	Declare @UnqForumCodeCnt as Int
   
      
	Set @CanSaveCus=N'N'      
      
	Select @ForumCode=Forumcode,@Cusid=Customerid,@CusName=Company_name,       
	@MemberShipCode=MemberShipCode From ReceivedCustomers      
	Where Id=@ID      
      
	If IsNull(@MemberShipCode,N'') = N''      
	Begin      
		Select @CountCus=Count(*) from customer Where AlternateCode =@ForumCode And CustomerID =@Cusid And Company_Name=@CusName      
		IF (@CountCus =1)      
			Set @CanSaveCus=N'E'      
		Else      
		begin      
			Select @CountCus=Count(*) from customer Where AlternateCode =@ForumCode or CustomerID =@Cusid or Company_Name=@CusName      
			if(@CountCus=0)      
				Set @CanSaveCus=N'N'       
			Else
			Begin
				Select @CountCus = Count(*) from customer Where CustomerID = @Cusid 
				IF (@CountCus =1)
					--Allows to update  the forumCode for the existing customer.
					--Provided the forumcode  should not exist for any other customer.
					--Updation will be based on the customerid
				Begin
					--Select @UnqCustNameCnt = Count(*) from customer Where Company_Name = @CusName And CustomerID <> @Cusid 
					Select @UnqForumCodeCnt = Count(*) from customer Where AlternateCode = @ForumCode And CustomerID <> @Cusid 
					IF (@UnqForumCodeCnt = 0) 
						Set @CanSaveCus=N'E'
				End
				Else
					Set @CanSaveCus=N'N'
				
			End          
		End      
	End      
	Else      
	Begin      
		Select @CountCus=Count(*) from customer Where MemberShipCode =@MemberShipCode and CustomerID = @Cusid And Company_Name=@CusName      
		IF (@CountCus =1)      
			Set @CanSaveCus=N'E'      
		Else      
		begin      
			Select @CountCus=Count(*) from customer Where MemberShipCode =@MemberShipCode or CustomerID = @Cusid or Company_Name=@CusName         
			if(@CountCus=0)      
				Set @CanSaveCus=N'N'       
			Else 
			Begin     
				Select @CountCus = Count(*) from customer Where CustomerID = @Cusid 
				IF (@CountCus =1)
				Begin
					--Allows To change the  forumCode for the existing customer.
					--Provided the forumcode  should not exist for any other customer.
					--Updation will be based on the customerid
					--Select @UnqCustNameCnt = Count(*) from customer Where Company_Name = @CusName And CustomerID <> @Cusid 
					Select @UnqForumCodeCnt = Count(*) from customer Where MemberShipCode = @MemberShipCode And CustomerID <> @Cusid 
					IF (@UnqForumCodeCnt = 0) 
						Set @CanSaveCus=N'E'
				End
				Else
					Set @CanSaveCus=N'N'         
			End
		End      
	End      
Return (Select @CanSaveCus)      
End      
      
