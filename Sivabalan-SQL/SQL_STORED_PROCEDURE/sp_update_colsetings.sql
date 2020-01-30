CREATE procedure sp_update_colsetings(@Batch int,@Expiry int,@Sale int,@Quantity Decimal(18,6),@Remarks int,@id int)        
as        
declare @offset int      
set @offset=10+((@id-1)*5)      
update formatinfo set colwidth=@Batch where Formatid=@offset 
if @@Rowcount=0 
insert into formatinfo(Formatid,ColWidth)values(@offset,@Batch)    
update formatinfo set colwidth=@Expiry where Formatid=@offset+1        
if @@Rowcount=0 
insert into formatinfo(Formatid,ColWidth)values(@offset+1,@Expiry)
update formatinfo set colwidth=@Sale where Formatid=@offset+2
if @@Rowcount=0 
insert into formatinfo(Formatid,ColWidth)values(@offset+2,@Sale)        
update formatinfo set colwidth=@Quantity where Formatid=@offset+3
if @@Rowcount=0 
insert into formatinfo(Formatid,ColWidth)values(@offset+3,@Quantity)      
update formatinfo set colwidth=@Remarks where Formatid=@offset+4      
if @@Rowcount=0 
insert into formatinfo(Formatid,ColWidth)values(@offset+4,@Remarks)    

      
    
    


