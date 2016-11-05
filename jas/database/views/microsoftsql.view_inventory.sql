CREATE OR REPLACE VIEW view_inventory AS
SELECT
  JProd_JProduct_UID as ProductUID,
  JProd_Number as ProductNo,
  JProd_Name as Name,
  JPrdG_Name as ProductGroup,
  JProd_Cost_d as CostEach,
  JProd_Price_d as PriceEach,
  JProd_Desc as Description,
  juser.JUser_Name as ProdCreatedBy,
  JProd_Created_DT as ProdCreated,
  juser2.JUser_Name as ProdModifiedBy,
  JProd_Modified_DT as ProdModified,
  JPrdQ_JProductQty_UID as ProdQtyUID,
  JComp_Name as Location,
  JPrdQ_QtyOnHand_d as QtyOnHand,
  JPrdQ_QtyOnOrder_d as QtyOnOrder,
  JPrdQ_QtyOnBackOrder_d QtyOnBackOrder,
  juser3.JUser_Name as QtyRecCreatedBy,
  JPrdQ_Created_DT as QtyRecCreated,
  juser4.JUser_Name as QtyRecModifiedBy,
  JPrdQ_Modified_DT as QtyRecModified

FROM jproductqty

LEFT JOIN jproduct on JProd_JProduct_UID = JPrdQ_JProduct_ID
LEFT JOIN jproductgrp ON JPrdG_JProductGrp_UID=JProd_JProductGrp_ID
LEFT JOIN jcompany ON JComp_JCompany_UID=JPrdQ_Location_JCompany_ID
LEFT JOIN juser ON juser.JUser_JUser_UID=JProd_CreatedBy_JUser_ID
LEFT JOIN juser as juser2 ON juser2.JUser_JUser_UID=JProd_ModifiedBy_JUser_ID
LEFT JOIN juser as juser3 ON juser3.JUser_JUser_UID=JPrdQ_CreatedBy_JUser_ID
LEFT JOIN juser as juser4 ON juser4.JUser_JUser_UID=JPrdQ_ModifiedBy_JUser_ID

WHERE ((JPrdQ_Deleted_b<>true)OR(JPrdQ_Deleted_b IS NULL))
ORDER BY JComp_Name, JProd_Number


 
