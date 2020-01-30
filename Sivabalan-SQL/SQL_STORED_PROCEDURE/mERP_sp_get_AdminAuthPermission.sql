CREATE Procedure mERP_sp_get_AdminAuthPermission(@UserName nVarchar(255), @AuthType Int)  
As  
Begin  
  Declare @GroupName nVarchar(255)  
  Declare @IndexVal INT  
  Declare @Lenght Int  
  Select @GroupName = GroupName from Users Where UserName Like @UserName /*And GroupName Like N'Administrator'*/  
  If @AuthType = 1  
    Begin  
    SET @Lenght = Len('Back Dated Transaction')  
    SELECT @IndexVal = CHARINDEX('Back Dated Transaction', Permission) FROM Groups WHERE GroupName=@GroupName  
    End   
  Else If @AuthType = 2  
    Begin  
    SET @Lenght = Len('Purchase Bill - PTR Changes')  
    SELECT @IndexVal = CHARINDEX('Purchase Bill - PTR Changes', Permission) FROM Groups WHERE GroupName=@GroupName  
    end  
  Else If @AuthType = 3  
    Begin  
    SET @Lenght = Len('Credit Management')  
    SELECT @IndexVal = CHARINDEX('Credit Management', Permission) FROM Groups WHERE GroupName=@GroupName  
    End   
  Else If @AuthType = 4  
    Begin  
    SET @Lenght = Len('Day Close')  
    SELECT @IndexVal = CHARINDEX('Day Close', Permission) FROM Groups WHERE GroupName=@GroupName  
    End   
  Else If @AuthType = 5  
    Begin  
    SET @Lenght = Len('View Performance Metrics')  
    SELECT @IndexVal = CHARINDEX('View Performance Metrics', Permission) FROM Groups WHERE GroupName=@GroupName  
    End   
  Else If @AuthType = 6  
    Begin  
    SET @Lenght = Len('CLO Credit Note')  
    SELECT @IndexVal = CHARINDEX('CLO Credit Note', Permission) FROM Groups WHERE GroupName=@GroupName  
    End   
  Else If @AuthType = 7
    Begin  
    SET @Lenght = Len('D & D')  
    SELECT @IndexVal = CHARINDEX('D & D', Permission) FROM Groups WHERE GroupName=@GroupName  
    End   
  Else If @AuthType = 8
    Begin  
    SET @Lenght = Len('DSType Planning')  
    SELECT @IndexVal = CHARINDEX('DSType Planning', Permission) FROM Groups WHERE GroupName=@GroupName  
    End   
  If @IndexVal > 0  
  Begin  
    Set @IndexVal = @IndexVal + @Lenght   
    DECLARE @val varbinary(16)  
    SELECT @val = TEXTPTR(Permission)   
    FROM Groups  
    WHERE GroupName=@GroupName  
    READTEXT Groups.Permission @val @IndexVal 2  
  End  
  Else   
  Select 0   
End
