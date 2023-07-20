create table Housing_data(UniqueID 			varchar,
						  ParcelID          varchar,
						  LandUse	        varchar,
						  PropertyAddress   varchar,
						  SaleDate 			varchar,
						  SalePrice 		varchar,
						  LegalReference 	varchar,
						  SoldAsVacant		varchar,
						  OwnerName		    varchar,
						  OwnerAddress		varchar,
						  Acreage 			varchar,
						  TaxDistrict 		varchar,
						  LandValue		    varchar,
						  BuildingValue 	varchar,
						  TotalValue 		varchar,
						  YearBuilt	 		varchar,
						  Bedrooms 			varchar,
						  FullBath 			varchar,
						  HalfBath		    varchar)

select * from housing_data;

--changing data type 
alter table housing_data
alter column uniqueid type int USING uniqueid::integer;

alter table housing_data
rename column uniqueid to unique_id;

alter table housing_data
rename column parcelid to percel_id;

alter table housing_data
rename column landuse to land_use;

alter table housing_data
rename column propertyaddress to property_address;

alter table housing_data
rename column saledate to sales_date;

alter table housing_data
rename column saleprice to sales_price;

alter table housing_data
rename column legalreference to legal_reference_number;

alter table housing_data
rename column soldasvacant to sold_as_vacant;

alter table housing_data
rename column ownername to owner_name;

alter table housing_data
rename column owneraddress to owner_address;

alter table housing_data
rename column acreage to acre_age;

alter table housing_data
rename column taxdistrict to tax_district;

alter table housing_data
rename column landvalue to land_value;

alter table housing_data
rename column buildingvalue to building_value;

alter table housing_data
rename column totalvalue to total_value;

alter table housing_data
rename column yearbuilt to year_built;

alter table housing_data
rename column bedrooms to bed_rooms;

alter table housing_data
rename column fullbath to full_bath;

alter table housing_data
rename column halfbath to half_bath;

update housing_data
set sales_date = sales_date::date;

alter table housing_data
alter column sales_date type date using sales_date::date;

update housing_data
set sales_price = replace(sales_price , ',' ,'');

update housing_data
set sales_price = replace(sales_price , '$','');

alter table housing_data
alter column saleprice type int using saleprice::int;

select soldasvacant , count(*)
from housing_data
group by soldasvacant;

--there are some column in soldasvacant as Y N replacing that as Yes , NO
update housing_data
set sold_as_vacant = case when sold_as_vacant = 'Y' then 'Yes' 
						when sold_as_vacant = 'N' then 'No'
						else sold_as_vacant 
					end;
	
alter table housing_data
alter column land_value type int using land_value::int;

update housing_data
set property_address =  h2.property_address
						from housing_data as h1
						inner join housing_data as h2 on h1.percel_id = h2.percel_id and h1.unique_id <> h2.unique_id
						where h1.property_address is null;
						
alter table housing_data
add property_split_address varchar;

update housing_data
set property_split_address = substr(property_address ,0, POSITION(',' in property_address));

alter table housing_data
add property_city varchar;

update housing_data
set property_city = substr(property_address , position(',' in property_address) + 1);

alter table housing_data
drop property_address;

alter table housing_data
rename column property_split_address to property_street;

select * from housing_data;

alter table housing_data
add owner_street varchar;

alter table housing_data
add owner_city varchar;

alter table housing_data
add onwer_state varchar;

update housing_data
set owner_street =  SPLIT_PART(owner_address, ',', 1);

update housing_data
set owner_city =  SPLIT_PART(owner_address, ',', 2);

update housing_data
set onwer_state =  SPLIT_PART(owner_address, ',', 3);

alter table housing_data
drop owner_address;

alter table housing_data
alter column acre_age type float using acre_age::float;

alter table housing_data
alter column land_value type int using land_value::int;

alter table housing_data
alter column building_value type int using building_value::int;

alter table housing_data
alter column total_value type int using total_value::int;

alter table housing_data
alter column year_built type int using year_built::int;

alter table housing_data
alter column bed_rooms type int using bed_rooms::int;

alter table housing_data
alter column full_bath type int using full_bath::int;

alter table housing_data
alter column half_bath type int using half_bath::int;

select * from housing_data
