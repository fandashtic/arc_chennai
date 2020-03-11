Select * into CustomerCreditLimit_Bak_10Feb2020 From CustomerCreditLimit

Declare @ProductCategoryGroup as Table (id Int Identity (1,1), GroupID int)
Insert into	@ProductCategoryGroup(GroupID) Select 2 UNION ALL Select 4 UNION ALL Select 5 UNION ALL Select 6 UNION ALL Select 7

Declare @CreditTerm as Table (id Int Identity (1,1), CreditID int)
Insert into	@CreditTerm(CreditID) select distinct CreditID from CreditTerm Where Active = 1

Declare @Customer as Table (id Int Identity (1,1), CustomerID Nvarchar(255))

Insert into @Customer(CustomerID)
Select 'ARC-CIG-118' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-005' Union ALL
Select 'ARC-CIG-179' Union ALL
Select 'ARC-CIG-3035' Union ALL
Select 'ARC-CIG-024' Union ALL
Select 'ARC-CIG-3056' Union ALL
Select 'ARC-CIG-253' Union ALL
Select 'ARC-CIG-032' Union ALL
Select 'ARC-CIG-054' Union ALL
Select 'ARC-CIG-332' Union ALL
Select 'ARC-CIG-028' Union ALL
Select 'ARCCNV42' Union ALL
Select 'ARC-CIG-252' Union ALL
Select 'ARC-CIG-035' Union ALL
Select 'ARC-CIG-016' Union ALL
Select 'ARC-CIG-3040' Union ALL
Select 'ARC-CIG-303' Union ALL
Select 'ARC-CIG-278' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-3020' Union ALL
Select 'ARC-CIG-146' Union ALL
Select 'ARC-CIG-145' Union ALL
Select 'ARC-CIG-080' Union ALL
Select 'ARC-CIG-3057' Union ALL
Select 'ARCCNV104' Union ALL
Select 'ARC-CIG-052' Union ALL
Select 'ARC-CIG-053' Union ALL
Select 'ARC-CIG-213' Union ALL
Select 'ARC-CIG-043' Union ALL
Select 'ARC-CIG-183' Union ALL
Select 'ARCCNV115' Union ALL
Select 'ARC-CIG-205' Union ALL
Select 'ARC-CIG-3073' Union ALL
Select 'ARC-CIG-163' Union ALL
Select 'ARC-CIG-3015' Union ALL
Select 'ARC-CIG-3016' Union ALL
Select 'ARC-CIG-3017' Union ALL
Select 'ARC-CIG-3019' Union ALL
Select 'ARC-CIG-2031' Union ALL
Select 'ARC-CIG-3053' Union ALL
Select 'ARC-CIG-3022' Union ALL
Select 'ARC-CIG-052' Union ALL
Select 'ARC-CIG-043' Union ALL
Select 'ARCCNV115' Union ALL
Select 'ARC-CIG-205' Union ALL
Select 'ARC-CIG-183' Union ALL
Select 'ARCCNV24' Union ALL
Select 'ARC-CIG-257' Union ALL
Select 'ARC-CIG-153' Union ALL
Select 'ARC-CIG-151' Union ALL
Select 'ARC-CIG-186' Union ALL
Select 'ARC-CIG-061' Union ALL
Select 'ARC-CIG-270' Union ALL
Select 'ARC-CIG-268' Union ALL
Select 'ARC-CIG-288' Union ALL
Select 'ARC-CIG-204' Union ALL
Select 'ARC-CIG-272' Union ALL
Select 'ARC-CIG-271' Union ALL
Select 'ARC-CIG-267' Union ALL
Select 'ARC-CIG-3033' Union ALL
Select 'ARC-CIG-146' Union ALL
Select 'ARC-CIG-046' Union ALL
Select 'ARC-CIG-024' Union ALL
Select 'ARC-CIG-3056' Union ALL
Select 'ARC-CIG-253' Union ALL
Select 'ARC-CIG-054' Union ALL
Select 'ARC-CIG-032' Union ALL
Select 'ARC-CIG-333' Union ALL
Select 'ARC-CIG-028' Union ALL
Select 'ARC-CIG-118' Union ALL
Select 'ARC-CIG-332' Union ALL
Select 'ARC-CIG-035' Union ALL
Select 'ARC-CIG-016' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-3020' Union ALL
Select 'ARC-CIG-005' Union ALL
Select 'ARC-CIG-154' Union ALL
Select 'ARCCNV104' Union ALL
Select 'ARC-CIG-3073' Union ALL
Select 'ARC-CIG-2031' Union ALL
Select 'ARC-CIG-3015' Union ALL
Select 'ARC-CIG-3053' Union ALL
Select 'ARC-CIG-3022' Union ALL
Select 'ARC-CIG-052' Union ALL
Select 'ARC-CIG-303' Union ALL
Select 'ARC-CIG-035' Union ALL
Select 'ARC-CIG-3040' Union ALL
Select 'ARC-CIG-402' Union ALL
Select 'ARC-CIG-024' Union ALL
Select 'ARC-CIG-032' Union ALL
Select 'ARC-CIG-285' Union ALL
Select 'ARC-CIG-287' Union ALL
Select 'ARC-CIG-028' Union ALL
Select 'ARC-CIG-261' Union ALL
Select 'ARC-CIG-080' Union ALL
Select 'ARC-CIG-146' Union ALL
Select 'ARC-CIG-3021' Union ALL
Select 'ARC-CIG-227' Union ALL
Select 'ARC-CIG-264' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-005' Union ALL
Select 'ARC-CIG-3056' Union ALL
Select 'ARC-CIG-180' Union ALL
Select 'ARC-CIG-054' Union ALL
Select 'ARC-CIG-333' Union ALL
Select 'ARC-CIG-213' Union ALL
Select 'ARC-CIG-051' Union ALL
Select 'ARCCNV42' Union ALL
Select 'ARC-CIG-332' Union ALL
Select 'ARC-CIG-345' Union ALL
Select 'ARC-CIG-035' Union ALL
Select 'ARC-CIG-209' Union ALL
Select 'ARC-CIG-3057' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-3020' Union ALL
Select 'ARC-CIG-256' Union ALL
Select 'ARC-CIG-3060' Union ALL
Select 'ARC-CIG-154' Union ALL
Select 'ARCCNV104' Union ALL
Select 'ARC-CIG-3006' Union ALL
Select 'ARC-CIG-270' Union ALL
Select 'ARC-CIG-35' Union ALL
Select 'ARC-CIG-32' Union ALL
Select 'ARC-CIG-268' Union ALL
Select 'ARC-CIG-204' Union ALL
Select 'ARC-CIG-272' Union ALL
Select 'ARC-CIG-271' Union ALL
Select 'ARC-CIG-267' Union ALL
Select 'ARC-CIG-3022' Union ALL
Select 'ARC-CIG-289' Union ALL
Select 'ARC-CIG-214' Union ALL
Select 'ARC-CIG-3030' Union ALL
Select 'ARC-CIG-3033' Union ALL
Select 'ARC-CIG-260' Union ALL
Select 'ARC-CIG-3017' Union ALL
Select 'ARC-CIG-3016' Union ALL
Select 'ARC-CIG-2031' Union ALL
Select 'ARC-CIG-3019' Union ALL
Select 'ARC-CIG-3053' Union ALL
Select 'ARC-CIG-187' Union ALL
Select 'ARC-CIG-188' Union ALL
Select 'ARC-CIG-3022' Union ALL
Select 'ARC-CIG-3015' Union ALL
Select 'ARC-CIG-3017' Union ALL
Select 'ARC-CIG-2031' Union ALL
Select 'ARC-CIG-3019' Union ALL
Select 'ARC-CIG-3016' Union ALL
Select 'ARC-CIG-3053' Union ALL
Select 'ARC-CIG-183' Union ALL
Select 'ARCCNV24' Union ALL
Select 'ARC-CIG-035' Union ALL
Select 'ARC-CIG-146' Union ALL
Select 'ARC-CIG-054' Union ALL
Select 'ARC-CIG-024' Union ALL
Select 'ARC-CIG-3056' Union ALL
Select 'ARC-CIG-016' Union ALL
Select 'ARC-CIG-3021' Union ALL
Select 'ARC-CIG-028' Union ALL
Select 'ARC-CIG-032' Union ALL
Select 'ARC-CIG-333' Union ALL
Select 'ARC-CIG-332' Union ALL
Select 'ARC-CIG-348' Union ALL
Select 'ARC-CIG-182' Union ALL
Select 'ARC-CIG-303' Union ALL
Select 'ARC-CIG-278' Union ALL
Select 'ARC-CIG-274' Union ALL
Select 'ARC-CIG-253' Union ALL
Select 'ARC-CIG-224' Union ALL
Select 'ARC-CIG-169' Union ALL
Select 'ARC-CIG-167' Union ALL
Select 'ARC-CIG-052' Union ALL
Select 'ARC-CIG-213' Union ALL
Select 'ARC-CIG-043' Union ALL
Select 'ARC-CIG-205' Union ALL
Select 'ARC-CIG-3073' Union ALL
Select 'ARCCNV109' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-173' Union ALL
Select 'ARC-CIG-163' Union ALL
Select 'ARC-CIG-176' Union ALL
Select 'ARC-CIG-137' Union ALL
Select 'ARC-CIG-063' Union ALL
Select 'ARC-CIG-152' Union ALL
Select 'ARC-CIG-071' Union ALL
Select 'ARC-CIG-153' Union ALL
Select 'ARC-CIG-207' Union ALL
Select 'ARC-CIG-174' Union ALL
Select 'ARC-CIG-052' Union ALL
Select 'ARC-CIG-213' Union ALL
Select 'ARC-CIG-053' Union ALL
Select 'ARC-CIG-043' Union ALL
Select 'ARC-CIG-205' Union ALL
Select 'ARC-CIG-261' Union ALL
Select 'ARC-CIG-145' Union ALL
Select 'ARC-CIG-024' Union ALL
Select 'ARC-CIG-3056' Union ALL
Select 'ARC-CIG-3021' Union ALL
Select 'ARC-CIG-046' Union ALL
Select 'ARC-CIG-054' Union ALL
Select 'ARC-CIG-032' Union ALL
Select 'ARC-CIG-028' Union ALL
Select 'ARC-CIG-332' Union ALL
Select 'ARC-CIG-222' Union ALL
Select 'ARC-CIG-345' Union ALL
Select 'ARC-CIG-035' Union ALL
Select 'ARC-CIG-118' Union ALL
Select 'ARC-CIG-186' Union ALL
Select 'ARC-CIG-151' Union ALL
Select 'ARC-CIG-061' Union ALL
Select 'ARC-CIG-3011' Union ALL
Select 'ARC-CIG-289' Union ALL
Select 'ARC-CIG-3057' Union ALL
Select 'ARC-CIG-303' Union ALL
Select 'ARC-CIG-278' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-3020' Union ALL
Select 'ARC-CIG-209' Union ALL
Select 'ARC-CIG-154' Union ALL
Select 'ARC-CIG-080' Union ALL
Select 'ARC-CIG-137' Union ALL
Select 'ARCCNV104' Union ALL
Select 'ARC-CIG-156' Union ALL
Select 'ARC-CIG-163' Union ALL
Select 'ARCCNV42' Union ALL
Select 'ARC-CIG-252' Union ALL
Select 'ARC-CIG-251' Union ALL
Select 'ARC-CIG-016' Union ALL
Select 'ARC-CIG-336' Union ALL
Select 'ARC-CIG-005' Union ALL
Select 'ARC-CIG-155' Union ALL
Select 'ARC-CIG-063' Union ALL
Select 'ARC-CIG-2031' Union ALL
Select 'ARC-CIG-3017' Union ALL
Select 'ARC-CIG-3015' Union ALL
Select 'ARC-CIG-3019' Union ALL
Select 'ARC-CIG-3053' Union ALL
Select 'ARC-CIG-3016' Union ALL
Select 'ARC-CIG-284' Union ALL
Select 'ARC-CIG-3022' Union ALL
Select 'ARC-CIG-187' Union ALL
Select 'ARC-CIG-289' Union ALL
Select 'ARC-CIG-208' Union ALL
Select 'ARC-CIG-214' Union ALL
Select 'ARC-CIG-3030' Union ALL
Select 'ARC-CIG-183' Union ALL
Select 'ARCCNV24' Union ALL
Select 'ARC-CIG-270' Union ALL
Select 'ARC-CIG-268' Union ALL
Select 'ARC-CIG-288' Union ALL
Select 'ARC-CIG-051' Union ALL
Select 'ARC-CIG-204' Union ALL
Select 'ARC-CIG-272' Union ALL
Select 'ARC-CIG-271' Union ALL
Select 'ARC-CIG-267' Union ALL
Select 'ARC-CIG-287' Union ALL
Select 'ARC-CIG-269' Union ALL
Select 'ARC-CIG-281' Union ALL
Select 'ARC-CIG-206' Union ALL
Select 'ARCCNV44' Union ALL
Select 'ARC-CIG-3061' Union ALL
Select 'ARC-CIG-250' Union ALL
Select 'ARC-CIG-198' Union ALL
Select 'ARC-CIG-333' Union ALL
Select 'ARC-CIG-147' Union ALL
Select 'ARC-CIG-180' Union ALL
Select 'ARC-CIG-3055' Union ALL
Select 'ARC-CIG-167' Union ALL
Select 'ARC-CIG-175' Union ALL
Select 'ARC-CIG-148' Union ALL
Select 'ARC-CIG-169' Union ALL
Select 'ARC-CIG-229' Union ALL
Select 'ARC-CIG-256' Union ALL
Select 'ARC-CIG-255' Union ALL
Select 'ARC-CIG-201' Union ALL
Select 'ARC-CIG-056' Union ALL
Select 'ARC-CIG-165' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-163' Union ALL
Select 'ARC-CIG-3060' Union ALL
Select 'ARC-CIG-211' Union ALL
Select 'ARC-CIG-3040' Union ALL
Select 'ARC-CIG-3058' Union ALL
Select 'ARC-CIG-361' Union ALL
Select 'ARC-CIG-352' Union ALL
Select 'ARC-CIG-36' Union ALL
Select 'ARC-CIG-37' Union ALL
Select 'ARC-CIG-38' Union ALL
Select 'ARC-CIG-186' Union ALL
Select 'ARC-CIG-266' Union ALL
Select 'ARC-CIG-048' Union ALL
Select 'ARC-CIG-207' Union ALL
Select 'ARC-CIG-3073' Union ALL
Select 'ARC-CIG-423' Union ALL
Select 'ARC-CIG-137' Union ALL
Select 'ARC-CIG-35' Union ALL
Select 'ARC-CIG-3017' Union ALL
Select 'ARC-CIG-3015' Union ALL
Select 'ARC-CIG-3016' Union ALL
Select 'ARC-CIG-3053' Union ALL
Select 'ARC-CIG-2031' Union ALL
Select 'ARC-CIG-3019' 

select * from @Customer
Declare @Id int
Declare @gid int
Declare @cid int
Declare @GroupId int
Declare @CreditID int
Declare @CustomerId as Nvarchar(255)
set @Id = 1
set @gid = 1
set @cid = 1

While(@Id <= (Select Max(id) From @Customer))
begin
	Select @CustomerId = CustomerId From @Customer Where Id = @Id
	set @gid = 1

	while(@gid <= (select max(id) from @ProductCategoryGroup))
	begin
		Select @GroupId = GroupId From @ProductCategoryGroup Where Id =  @gid
		--If Not Exists(Select top 1 1 from CustomerCreditLimit with (nolock) where CustomerID = @CustomerId and GroupID = @GroupId)
		--begin

			SET @cid = 1

			while(@cid <= (select max(id) from @CreditTerm))
			begin
				Select @CreditID = CreditID From @CreditTerm Where Id =  @cid
				If Not Exists(Select top 1 1 from CustomerCreditLimit with (nolock) where CustomerID = @CustomerId and GroupID = @GroupId AND CreditTermDays = @CreditID)
				begin
					Insert into CustomerCreditLimit Select @CustomerId, @GroupId, @CreditID, 0, -1
				end
				set @cid = @cid + 1
			end

		--end
		set @gid = @gid + 1
	end

	set @Id = @id + 1
end

delete From @ProductCategoryGroup
delete From @Customer
delete from @CreditTerm
