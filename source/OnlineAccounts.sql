-- DROP TABLE IF EXISTS OnlineAccounts;

CREATE TABLE IF NOT EXISTS OnlineAccounts
(
    `id` SERIAL PRIMARY KEY,

    -- Identification
    `serviceName`                       VARCHAR(32) NOT NULL COMMENT 'A short name for the service, such as "YOUTUBE".',
    `accountName`                       VARCHAR(64) COMMENT 'The username, handle, or other identifier used to log in.',
    `registeredEmailAddress`            TINYTEXT COMMENT 'The email address registerd with the service.',

    -- Lifecycle
    `status`                            VARCHAR(32) COMMENT 'A free-form description of the state of the account.',
    `creationDate`                      DATE COMMENT 'The day the account was created.',
    `closureDate`                       DATE COMMENT 'The day the account was closed.',
    `closureReason`                     TEXT COMMENT 'A short description of why the account was closed.',
    `closed`                            BOOLEAN COMMENT 'Whether the account was closed.',

    -- Data Usage
    `hasSocialSecurityNumber`           BOOLEAN COMMENT 'Whether the account has or uses the owner''s social security number.',
    `hasDriversLicenseNumber`           BOOLEAN COMMENT 'Whether the account has or uses the owner''s driver''s license number.',
    `hasPostalAddress`                  BOOLEAN COMMENT 'Whether the account has or uses the owner''s postal address.',
    `hasCreditCardInformation`          BOOLEAN COMMENT 'Whether the account has or uses the owner''s credit card information.',
    `hasOtherCredentials`               BOOLEAN COMMENT 'Whether the account has or uses the owner''s credentials to other services.',
    `hasTelephoneNumber`                BOOLEAN COMMENT 'Whether the account has or uses the owner''s telephone number.',
    `hasEmailAddress`                   BOOLEAN COMMENT 'Whether the account has or uses the owner''s email address.',
    `hasPersonalSecrets`                BOOLEAN COMMENT 'Whether the account has or uses the owner''s personal secrets.',
    `hasProfilePicture`                 BOOLEAN COMMENT 'Whether the account has or uses a picture of the owner''s face.',
    `hasLegalData`                      BOOLEAN COMMENT 'Whether the account has or uses the owner''s legal information, such as criminal history or current litigations.',
    `hasFinancialData`                  BOOLEAN COMMENT 'Whether the account has or uses the owner''s financial information, such as bank numbers or credit history.',
    `hasMedicalData`                    BOOLEAN COMMENT 'Whether the account has or uses the owner''s medical data, such as diagnosis codes or medication information.',
    `hasAcademicData`                   BOOLEAN COMMENT 'Whether the account has or uses the owner''s academic information, such as enrollment status, tuition, or grades.',
    `hasCryptoCurrencyKeys`             BOOLEAN COMMENT 'Whether the account has or uses the owner''s private keys to cryptocurrency wallets.',
    `hasCryptographicKeys`              BOOLEAN COMMENT 'Whether the account has or uses the owner''s cryptographic keys to something.',

    -- Security
    `multifactorAuthenticationEnabled`  BOOLEAN COMMENT 'Whether multi-factor authentication (MFA) is enabled for this account.',
    `multifactorAuthenticationMethod`   VARCHAR(32) COMMENT 'A description of the method used for multi-factor authentication (MFA).',

    -- Miscellaneous
    `governmentRelated`                 BOOLEAN COMMENT 'Whether the account is for a service that the government operates, such as the Department of Motor Vehicles (DMV).',
    `employerRelated`                   BOOLEAN COMMENT 'Whether the account was set up or is managed by the owner''s employer.',
    `hasMoney`                          BOOLEAN COMMENT 'Whether the account holds the owner''s money.',
    `serviceDescription`                TEXT COMMENT 'A description of the service or the account held with the service.',
    `notes`                             TEXT
);

ALTER TABLE OnlineAccounts
ADD UNIQUE INDEX (`serviceName`, `accountName`);

CREATE TRIGGER UppercaseServiceNameInOnlineAccounts
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.serviceName = UPPER(NEW.serviceName);

CREATE TRIGGER LowercaseEmailInOnlineAccounts
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.registeredEmailAddress = LOWER(NEW.registeredEmailAddress);

CREATE TRIGGER CloseAccountInOnlineAccounts
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.closed = (NEW.closureDate IS NOT NULL OR NEW.closureReason IS NOT NULL);

CREATE TRIGGER EnableMFAInOnlineAccounts
BEFORE INSERT ON OnlineAccounts FOR EACH ROW
    SET NEW.multifactorAuthenticationEnabled = (NEW.multifactorAuthenticationMethod IS NOT NULL);

CREATE VIEW IF NOT EXISTS OnlineAccountsToUpdateAfterMoving
AS
    SELECT serviceName, accountName, registeredEmailAddress
    FROM OnlineAccounts
    WHERE
        (hasPostalAddress = TRUE OR hasPostalAddress IS NULL) AND
        (closed = FALSE OR closed IS NULL) AND
        closureDate IS NULL AND
        closureReason IS NULL;

CREATE VIEW IF NOT EXISTS OnlineServicesWithMultipleAccounts
AS
    SELECT serviceName AS `Service Name`, COUNT(serviceName) as `Number of Accounts`
    FROM OnlineAccounts
    GROUP BY `Service Name`
    HAVING `Number of Accounts` > 1;