# Data-Cleaning-in-SQL

In this  project various statements and functions were applied to  clean and transform raw data on housing ('NashvilleHousing' table).

## Here is a summary of the statements and functions used:

1. Standardize sale date:
   - The 'ALTER TABLE' statement was used to add the 'SaleDateConverted' column to the 'NashvilleHousing' table.
   - The 'CONVERT' function was applied to convert the 'SaleDate' column values to the 'date' data type.
   - An 'UPDATE' statement was used to populate the 'SaleDateConverted' column with the converted values.

2. Populate property address:
    - a 'WHERE' clause was used to identify rows where the 'PropertyAddress' was null.
    - A self-join query using the 'JOIN' keyword was employed to combine values from multiple rows with the same 'ParcelID' but different 'UniqueID' when the 'PropertyAddress' was null.
    - An 'UPDATE' statement was used to populate the missing 'PropertyAddress' values by selecting the non-null value from the self-joined rows.

3. Break out address into individual columns:
    - The 'SUBSTRING' function, along with the 'CHARINDEX' function, was utilized to extract the 'Address' and 'City' components from the 'PropertyAddress' column.

4. Add new columns to the table:
    - The 'ALTER TABLE' statement was applied to add the 'PropertySplitAddress' and 'PropertySplitCity' columns to the 'NashvilleHousing' table.
    - 'UPDATE' statements were used to populate the newly created columns with the extracted values from the 'PropertyAddress' column.

5. Extract characters using 'PARSENAME':
     - The 'PARSENAME' function was employed to extract the 'Address,' 'City,' and 'State' components from the 'OwnerAddress' column.

6. Add new columns to the table:
    - The 'ALTER TABLE' statement was utilized to add the 'OwnerSplitAddress,' 'OwnerSplitCity,' and 'OwnerSplitState' columns to the 'NashvilleHousing' table.
    - 'UPDATE' statements were used to populate the newly created columns with the extracted values from the 'OwnerAddress' column.

7. Change 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant':
    - A 'CASE' statement was applied to replace 'Y' with 'Yes' and 'N' with 'No' in the 'SoldAsVacant' column.

8. Remove duplicates:
    - The 'ROW_NUMBER' function, in conjunction with a common table expression (CTE), was used to assign row numbers based on specific criteria.
    - A 'DELETE' statement was executed on the CTE to remove rows with row numbers greater than 1, effectively eliminating duplicates.

9. Delete unused columns:
    - The 'ALTER TABLE' statement was used to drop the 'OwnerAddress,' 'TaxDistrict,' 'PropertyAddress,' and 'SaleDate' columns from the 'NashvilleHousing' table.

```
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

```
