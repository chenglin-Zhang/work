USE [TPCentralDB]
GO
/****** Object:  StoredProcedure [dbo].[spr_rpt_UncountedReport]    Script Date: 12/8/2020 1:25:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[spr_rpt_UncountedReport]
--All全部收货状态 Yes已收货 No未收货
@IfGoods varchar(5),
--盘点单号
@szDocumentNmbr varchar(20),
--开始时间
@szFormData varchar(20),
--结束时间
@szToData varchar(20),
--门店号
@TemplRetailStoreID int
as
if @IfGoods='Yes'
begin
select p.lRetailStoreID, p.szPOSItemID,
i.szItemLookupCode, p.szDesc,ims.dLDU, 
dbo.IMfn_GetUnitPriceInStocktake(
@szDocumentNmbr, p.szPOSItemID, @szFormData) 
as price
 
from POSIdentity p 

left outer join 
(select t.* from (select ItemLookupCode.*,row_number() over (partition by szPosItemID order by szPosItemID  ) rn 
from ItemLookupCode) t where rn=1) 
as i
 
on i.szPOSItemID = p.szPOSItemID 

AND i.lRetailStoreID = p.lRetailStoreID 

left outer join  IMItemSource ims
 
on ims.szPOSItemID = p.szPOSItemID 

AND ims.lRetailStoreID = p.lRetailStoreID
where p.szPOSItemID in (

select aa.szPosItemID from 
(select szPosItemID from IMStockTakeItem 
where lRetailStoreID = @TemplRetailStoreID
and szDocumentNmbr = @szDocumentNmbr
 except 

select szPosItemID from IMStockTakeDetail 
where lRetailStoreID = @TemplRetailStoreID
and szDocumentNmbr = @szDocumentNmbr)  aa

inner join 
(select distinct(d.szPOSItemID) from IMMovement i
left outer join IMMovementDetail d
on i.szDocumentNmbr = d.szDocumentNmbr
 where i.lDocType in (1,2) and szDate >@szFormData and szDate < @szToData) bb
 on aa.szPosItemID = bb.szPOSItemID
)
end

else if @IfGoods='No'
begin
select p.lRetailStoreID, p.szPOSItemID,
i.szItemLookupCode, p.szDesc,ims.dLDU, 
dbo.IMfn_GetUnitPriceInStocktake(
@szDocumentNmbr, p.szPOSItemID, @szFormData) 
as price
 
from POSIdentity p 

left outer join 
(select t.* from (select ItemLookupCode.*,row_number() over (partition by szPosItemID order by szPosItemID  ) rn 
from ItemLookupCode) t where rn=1) 
as i
 
on i.szPOSItemID = p.szPOSItemID 

AND i.lRetailStoreID = p.lRetailStoreID 

left outer join  IMItemSource ims
 
on ims.szPOSItemID = p.szPOSItemID 

AND ims.lRetailStoreID = p.lRetailStoreID
where p.szPOSItemID in 

(select szPosItemID from IMStockTakeItem 
where lRetailStoreID = @TemplRetailStoreID
and szDocumentNmbr = @szDocumentNmbr
 except 

select szPosItemID from IMStockTakeDetail 
where lRetailStoreID = @TemplRetailStoreID
and szDocumentNmbr = @szDocumentNmbr

except
select distinct(d.szPOSItemID) from IMMovement i
left outer join IMMovementDetail d
on i.szDocumentNmbr = d.szDocumentNmbr
 where i.lDocType in (1,2) and szDate >=@szFormData and szDate <= @szToData
)
end

else

begin
select p.lRetailStoreID, p.szPOSItemID,
i.szItemLookupCode, p.szDesc,ims.dLDU, 
dbo.IMfn_GetUnitPriceInStocktake(
@szDocumentNmbr, p.szPOSItemID, @szFormData) 
as price
 
from POSIdentity p 

left outer join 
(select t.* from (select ItemLookupCode.*,row_number() over (partition by szPosItemID order by szPosItemID  ) rn 
from ItemLookupCode) t where rn=1) 
as i
 
on i.szPOSItemID = p.szPOSItemID 

AND i.lRetailStoreID = p.lRetailStoreID 

left outer join  IMItemSource ims
 
on ims.szPOSItemID = p.szPOSItemID 

AND ims.lRetailStoreID = p.lRetailStoreID
where p.szPOSItemID in 

(select szPosItemID from IMStockTakeItem 
where lRetailStoreID = @TemplRetailStoreID
and szDocumentNmbr = @szDocumentNmbr
 except 

select szPosItemID from IMStockTakeDetail 
where lRetailStoreID = @TemplRetailStoreID
and szDocumentNmbr = @szDocumentNmbr)
end