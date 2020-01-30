CREATE Procedure sp_acc_updateARVbatchassets(@BatchCode as int,@Saleable int,@ARVID int=0)
As
--@ARVID is Auto entry of an ARV
Update Batch_Assets set Saleable=@Saleable,ARVID=@ARVID where BatchCode=@BatchCode 

