


CREATE FUNCTION fn_Get_UserName(@SerialNo INT)
RETURNS nvarchar(4000) AS 
BEGIN

DECLARE @UserList nvarchar(4000)
DECLARE @UserName nvarchar(255)

SET @UserList = ''

DECLARE UserList CURSOR FOR SELECT UserName FROM DocumentUsers
WHERE SerialNo=@SerialNo

OPEN UserList

FETCH NEXT FROM UserList INTO @UserName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @UserList = @UserList + Char(13)+ @UserName 
FETCH NEXT FROM UserList INTO @UserName
END

CLOSE UserList
DEALLOCATE UserList



--if Len(@UserList) <> 0
--Set @UserList=(LEFT(@UserList,LEN(@UserList) - 1))

RETURN(@UserList)

END





