CREATE TABLE IF NOT EXISTS OnlineAccounts
(
    `id` SERIAL PRIMARY KEY,

    -- Identification
    `serviceName`                       VARCHAR(32) NOT NULL COMMENT 'A short name for the service, such as "YOUTUBE".',
    `accountName`                       VARCHAR(64) COMMENT 'The username, handle, or other identifier used to log in.',
    `registeredEmailAddress`            TINYTEXT COMMENT 'The email address registerd with the service.',

    -- Lifecycle
    `creationDate`                      DATE COMMENT 'The day the account was created.',
    `deletionDate`                      DATE COMMENT 'The day the account was deleted.',
    `deletionReason`                    TEXT COMMENT 'A short description of why the account was closed.',
    `deleted`                           BOOLEAN,
    `status`                            VARCHAR(32) COMMENT 'A free-form description of the state of the account.',

    -- Data Usage
    `hasSocialSecurityNumber`           BOOLEAN,
    `hasDriversLicenseNumber`           BOOLEAN,
    `hasPostalAddress`                  BOOLEAN,
    `hasCreditCardInformation`          BOOLEAN,
    `hasOtherCredentials`               BOOLEAN,
    `hasTelephoneNumber`                BOOLEAN,
    `hasEmailAddress`                   BOOLEAN,
    `hasPersonalSecrets`                BOOLEAN,
    `hasProfilePicture`                 BOOLEAN,
    `hasLegalData`                      BOOLEAN,
    `hasFinancialData`                  BOOLEAN,
    `hasMedicalData`                    BOOLEAN,
    `hasAcademicData`                   BOOLEAN,
    `hasCryptoCurrencyKeys`             BOOLEAN,
    `hasCryptographicKeys`              BOOLEAN,
    
    -- Security
    `multifactorAuthenticationEnabled`  BOOLEAN,
    `multifactorAuthenticationMethod`   VARCHAR(32)
);

CREATE TRIGGER UppercaseServiceName
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.serviceName = UPPER(NEW.serviceName);

CREATE TRIGGER LowercaseEmail
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.registeredEmailAddress = LOWER(NEW.registeredEmailAddress);

CREATE TRIGGER DeleteAccount
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.deleted = (NEW.deletionDate IS NOT NULL OR NEW.deletionReason IS NOT NULL);

CREATE TRIGGER EnableMFA
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.multifactorAuthenticationEnabled = (NEW.multifactorAuthenticationMethod IS NOT NULL);