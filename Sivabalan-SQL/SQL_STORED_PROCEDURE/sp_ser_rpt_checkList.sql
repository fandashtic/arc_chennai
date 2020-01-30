CREATE procedure sp_ser_rpt_checkList
as
select checklistmaster.CheckListID,'CheckListID' = checklistmaster.CheckListID,
'CheckList Name' = CheckListName,
(case CheckListMaster.Active when 1 then 'Active' when 0 then 'Deactive' 
else '' end) as 'Active'  from checklistmaster

