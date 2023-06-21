

select 
from [dbo].[NashivilleHousing]

--Standardize sale date

alter table NashivilleHousing
add SaleDateConverted date

update NashivilleHousing
set SaleDateConverted=CONVERT(date,SaleDate)

--pouplate Property address 

select *
from [dbo].[NashivilleHousing]
--where PropertyAddress is null
order by parcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from NashivilleHousing a
JOIN NashivilleHousing b
on a.ParcelID=b.parcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress, b.PropertyAddress)
from NashivilleHousing a
JOIN NashivilleHousing b
on a.ParcelID=b.parcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address  into individul coloumns (Address, city, state)

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, len(PropertyAddress)) as city
from NashivilleHousing

--adding the two new coloum to the table 

alter  table NashivilleHousing
add PropertySplitAddress nvarchar (255);

update NashivilleHousing
set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

alter  table NashivilleHousing
add PropertySplitCity nvarchar (255);

update NashivilleHousing
set PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, len(PropertyAddress)) 


--extracting characters using parsname 
select 
PARSENAME (replace (owneraddress, ',', '.'), 3),
PARSENAME (replace (owneraddress, ',', '.'), 2),
PARSENAME (replace (owneraddress, ',', '.'), 1)

from NashivilleHousing

-- adding the new columns to the table

alter table NashivilleHousing
add OwnerSplitAdress nvarchar (255);

update NashivilleHousing
set OwnerSplitAdress =PARSENAME (replace (owneraddress, ',', '.'), 3)



alter  table NashivilleHousing
add OwnerSplitCity nvarchar (255);

update NashivilleHousing
set OwnerSplitCity =PARSENAME (replace (owneraddress, ',', '.'), 2)



alter  table NashivilleHousing
add OwnerSplitState nvarchar (255);

update NashivilleHousing
set OwnerSplitState =PARSENAME (replace (owneraddress, ',', '.'), 1)

--change Y and N to yes and no in Sold as Vacant
 
select SoldAsVacant,
case  when SoldAsVacant='N' then 'No'
      when SoldAsVacant='Y' then 'Yes'
      else SoldAsVacant
      end
from NashivilleHousing


update NashivilleHousing
set SoldAsVacant = case  when SoldAsVacant='N' then 'No'
      when SoldAsVacant='Y' then 'Yes'
      else SoldAsVacant
      end

--Remove duplicates 

With RowNumCTE AS (
select*, 
ROW_NUMBER () over ( partition by 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by uniqueID
) row_num
from NashivilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
where row_num >1
--order by PropertyAddress

--Delete Unused coloumn
 
alter table NashivilleHousing
drop column OwnerAddress, TaxDistrict,PropertyAddress,SaleDate





