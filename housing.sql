select *
from portfolio..housing
-- convert datetime data type to date data type 
-- method 1 
alter table portfolio..housing
add ConvertedSaleDate date ;

update portfolio..housing
set ConvertedSaleDate =convert(date,Saledate)

alter table portfolio..housing 
drop column saleDate

alter table portfolio..housing
Rename column ConvertedSaleDate to Saledate

-- Method 2 (sql server)
alter table portfolio..housing 
alter column saledate date

-- populating properaddress data
select  a.ParcelID ,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio..housing a
join portfolio..housing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] != b.[UniqueID ]
 where a.PropertyAddress is null

 Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio..housing a
JOIN portfolio..housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

--spliting propertyaddress in streetaddress and city
select PropertyAddress 
From portfolio..housing
-- ',' is used for delimiter

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From portfolio..housing


ALTER TABLE portfolio..housing
Add StreetAddress Nvarchar(255);

Update portfolio..housing
SET streetaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE portfolio..housing
Add City Nvarchar(255);

Update portfolio..housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--spliting owneraddress into street , city , state 
-- with substring and charindex
select 
SUBSTRING (owneraddress , 1, charindex(',' ,owneraddress)-1 )as ownerstreetaddress,
SUBSTRING (owneraddress ,  charindex(',' ,owneraddress)+1, CHARINDEX(',',owneraddress,charindex(',',owneraddress)+1)-charindex(',' ,owneraddress)-1 )as ownercity ,
SUBSTRING (OwnerAddress,CHARINDEX(',',owneraddress,charindex(',',owneraddress)+1)+1,len(owneraddress)) as ownerstate
from portfolio..housing


--with parsename
select 
PARSENAME (REPLACE(owneraddress,',','.'),1)as ownerstate,
PARSENAME (REPLACE(owneraddress,',','.'),2)as ownercity,
PARSENAME (REPLACE(owneraddress,',','.'),3) as ownerstreetaddress
from portfolio..housing


alter table portfolio..housing 
add ownerstreetaddress nvarchar(255)

update portfolio..housing
set ownerstreetaddress =PARSENAME (REPLACE(owneraddress,',','.'),3)

alter table portfolio..housing 
add ownercity nvarchar(255)

update portfolio..housing
set ownercity =PARSENAME (REPLACE(owneraddress,',','.'),2)


alter table portfolio..housing 
add ownerstate nvarchar(255)

update portfolio..housing
set ownerstate =PARSENAME (REPLACE(owneraddress,',','.'),1)

--standardizing soldasvacant by converting 'Y'and'N' to 'Yes' and 'NO'
select distinct soldasvacant ,count(soldasvacant)
from portfolio..housing
group by SoldAsVacant

select count(soldasvacant),
  case 
    when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end as soldAsvacant
 from portfolio..housing
 group by soldasvacant

 update portfolio..housing
 set SoldAsVacant = case 
    when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end


	-- deleting duplicate
	
with rownum as
(
select *, 
    row_number() over( partition by
	                            parcelid,saleDate,saleprice,legalreference 
                        order by uniqueid ) as rownum                   
from portfolio..housing
)

delete
from rownum
where rownum > 1

-- Delete Unused Columns
ALTER TABLE portfolio..housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress