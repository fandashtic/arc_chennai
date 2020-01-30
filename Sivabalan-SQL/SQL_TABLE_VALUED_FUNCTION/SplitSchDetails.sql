Create function dbo.SplitSchDetails(@MultipleSchemeDetails nvarchar(4000))
returns @tmpSchData table( SchemeId Int, DscPercent decimal(18,6), DscAmount decimal(18,6))
--Declare @tmpSchData table( SchemeId Int, DscPercent decimal(18,6), DscAmount decimal(18,6))
--Declare @MultipleSchemeDetails nvarchar(4000)
--select @MultipleSchemeDetails  = '2448|192322|0.465751|0.995455ò449|192448|0.935750|1.999989'
As 
begin 
    Declare @SchemeDetails nvarchar(1000), @Delimiter char(1), @DelimiterSch char(1) 
    Declare @SchemeID Int, @DscPercent decimal(18,6), @DscAmount decimal(18,6), @cnt Int
    Declare @tmpSchemeDtl table ( Itemvalue Nvarchar(100))
    Declare @tmpSchDtl table ( Id int Identity(1, 1), Itemvalue Nvarchar(100))
    Select @Delimiter = char(15), @DelimiterSch = '|'
    If len(@MultipleSchemeDetails) > 0 
    begin 
        Insert Into @tmpSchemeDtl
        Select Itemvalue from dbo.sp_SplitIn2Rows( @MultipleSchemeDetails, @Delimiter )
        Delete @tmpSchemeDtl where len(Itemvalue) = 0
--        select * from @tmpSchemeDtl
        Declare SchCur Cursor for Select Itemvalue from @tmpSchemeDtl 
        Open SchCur
        Fetch next from SchCur into @SchemeDetails
        While(@@FETCH_STATUS =0)
        begin
            Insert Into @tmpSchDtl( Itemvalue)
            Select Itemvalue from dbo.sp_SplitIn2Rows( @SchemeDetails, @DelimiterSch )
            --select * from @tmpSchDtl
            Fetch next from SchCur into @SchemeDetails
        end
        Close SchCur
        Deallocate SchCur
        Select @Cnt = Count(*) from @tmpSchDtl 
        while @Cnt > 0 
        begin
            If @Cnt % 4 = 0
            begin
--                select @cnt
                Select @SchemeId = Convert(Decimal(18,6), Itemvalue) from @tmpSchDtl where Id = @Cnt - 3
                Select @DscAmount = Convert(Decimal(18,6), Itemvalue) from @tmpSchDtl where Id = @Cnt - 1
                Select @DscPercent = Convert(Decimal(18,6), Itemvalue) from @tmpSchDtl where Id = @Cnt
                
                Insert Into @tmpSchData (SchemeId, DscPercent, DscAmount ) Select @SchemeId, @DscPercent, @DscAmount
            End
            Select @cnt = @cnt - 1
        End
        --select * from @tmpSchData 
    end
    Return
end
