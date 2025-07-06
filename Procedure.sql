USE pet_adoption;

-- Stored Procedure: GetPetsByStatusAndSpecies
-- Retrieves pets filtered by status and species, with validation
DELIMITER //
CREATE PROCEDURE GetPetsByStatusAndSpecies(
    IN p_status ENUM('available', 'adopted'),
    IN p_species ENUM('dog', 'cat', 'bird', 'other'),
    OUT p_result_count INT
)
BEGIN
    IF p_status IS NULL OR p_species IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Status and species parameters cannot be NULL';
    ELSE     
        SELECT s.name AS shelter_name, p.name AS pet_name, p.species, p.age
        FROM pet p
        JOIN shelter s ON p.shelter_id = s.shelter_id
        WHERE p.status = p_status AND p.species = p_species;
        
	        SET p_result_count = (SELECT COUNT(*) 
                             FROM pet 
                             WHERE status = p_status AND species = p_species);
    END IF;
END //
DELIMITER ;

-- Function: GetPetAgeCategory
-- Returns the age category of a pet based on its age
DELIMITER //
CREATE FUNCTION GetPetAgeCategory(p_age INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE age_category VARCHAR(20);
    
    IF p_age IS NULL THEN
        SET age_category = 'Unknown';
    ELSEIF p_age <= 2 THEN
        SET age_category = 'Young';
    ELSEIF p_age <= 7 THEN
        SET age_category = 'Adult';
    ELSE
        SET age_category = 'Senior';
    END IF;
    
    RETURN age_category;
END //
DELIMITER ;


SET @result_count = 0;
CALL GetPetsByStatusAndSpecies('available', 'dog', @result_count);
SELECT @result_count AS matching_pets;

SET @result_count = 0;
CALL GetPetsByStatusAndSpecies('adopted', 'cat', @result_count);
SELECT @result_count AS matching_pets;

SELECT name, species, age, GetPetAgeCategory(age) AS age_category
FROM pet;

SELECT s.name AS shelter_name, p.name AS pet_name, p.age
FROM pet p
JOIN shelter s ON p.shelter_id = s.shelter_id
WHERE GetPetAgeCategory(p.age) = 'Young';