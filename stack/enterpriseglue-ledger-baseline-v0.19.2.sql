-- EnterpriseGlue The Bridge: migration-ledger baseline for databases created by the v0.19.x / v0.20.0 images.
--
-- Those published images did not ship their compiled TypeORM migrations at the path the runtime scans
-- (v0.19.x) or copied the sources outside the compiled tree (v0.20.0). On first start they therefore built
-- the schema with synchronize() but left the ledger table `main.migrations` EMPTY. Any later image
-- (v0.20.1+) then tries to re-run every migration from scratch and crashes at start-up (e.g.
-- `column "user_id" does not exist`). Images from v0.20.1 on contain a built-in recovery, but it is pinned
-- to the exact v0.20.0 inventory (132 migrations) and therefore fires neither for v0.19.x databases nor in
-- current images.
--
-- This script records the 131 migrations that a v0.19.2-built schema already embodies (everything up to
-- 1700000000129) as executed, so the current image only runs the newer ones. It refuses to run on a ledger
-- that is not empty and is applied in one transaction. Apply ONCE, before starting the new image:
--
--   docker exec -i enterpriseglue-db psql -v ON_ERROR_STOP=1 -U enterpriseglue -d enterpriseglue \
--     < stack/enterpriseglue-ledger-baseline-v0.19.2.sql
--   cd stack && docker-compose up -d
--
-- Alternative (loses all Bridge data, which is fine for a fresh training setup): remove the Bridge containers
-- and volumes and start again:
--   cd stack && docker-compose rm -sf enterpriseglue-frontend enterpriseglue-backend enterpriseglue-db \
--     && docker volume rm stack_enterpriseglue_postgres_data stack_enterpriseglue_git_repos && docker-compose up -d
-- (Do NOT use `docker-compose down -v` – that would also wipe the training engine's PostgreSQL data.)

BEGIN;

DO $$
DECLARE existing integer;
BEGIN
  SELECT count(*) INTO existing FROM main.migrations;
  IF existing > 0 THEN
    RAISE EXCEPTION 'main.migrations already contains % row(s) – this baseline only applies to an EMPTY ledger', existing;
  END IF;
END $$;

INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000000, 'AddFileLinkColumns1700000000000');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000001, 'AddNotificationsTable1700000000001');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000002, 'AddPasswordResetTokensTable1700000000002');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000003, 'MigrateGitTokenToProject1700000000003');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000004, 'DropGitCredentials1700000000004');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000005, 'AddPiiSettings1700000000005');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000006, 'AddSsoAutoRedirectSingleProvider1700000000006');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000007, 'UpdateDefaultDeployRoles1700000000007');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000008, 'AddHotfixMetadata1700000000008');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000009, 'AddWorkingFilesMainFileId1700000000009');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000010, 'AddFileSnapshotsMainFileId1700000000010');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000011, 'AddInvitationsTable1700000000011');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000012, 'RepairInvitationsLegacySchema1700000000012');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000013, 'CleanupLegacyInvitationsSchema1700000000013');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000014, 'AddGitLockSessionState1700000000014');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000015, 'AddEngineOauthClientCredentials1700000000015');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000016, 'AddRbacFoundation1700000000016');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000017, 'AddExternalEngineRegistration1700000000017');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000018, 'AddApiClients1700000000018');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000019, 'AddExternalEngineRegistrationsTable1700000000019');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000020, 'AddCustomPermissionMetadata1700000000020');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000021, 'AddAuthzTenantScope1700000000021');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000022, 'AddPrincipalRoleAssignmentShape1700000000022');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000023, 'AddAuthzGroups1700000000023');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000024, 'AddSsoGroupMappings1700000000024');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000025, 'AddEngineSets1700000000025');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000026, 'AddProjectEngineTargets1700000000026');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000027, 'AddServiceAccounts1700000000027');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000028, 'AddServiceAccountTokenFields1700000000028');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000029, 'AddEngineOnboardingMode1700000000029');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000030, 'AddExternalEngineSystems1700000000030');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000031, 'AddExternalEngineLifecycle1700000000031');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000032, 'AddExternalEngineCapabilities1700000000032');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000033, 'AddProjectEngineTargetPolicyMode1700000000033');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000034, 'AddProjectEngineTargetMetadata1700000000034');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000035, 'AddSsoAllEnginesAssignmentSetting1700000000035');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000036, 'AddSsoGovernanceAssignmentSettings1700000000036');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000037, 'AddSsoSyncDiagnostics1700000000037');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000038, 'AddSsoNormalizedIdentities1700000000038');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000039, 'AddSsoClaimOperators1700000000039');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000040, 'AddSsoRegexClaimMappingSetting1700000000040');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000041, 'AddSsoSensitivePermissionMappingSettings1700000000041');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000042, 'AddSsoEngineAccessSnapshotsAndAccessAuthority1700000000042');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000043, 'NormalizeOssDefaultTenantId1700000000043');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000044, 'AddEngineRuntimeAuthorizationMode1700000000044');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000045, 'AddCanonicalRoleAssignmentKey1700000000045');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000046, 'MakeRoleAssignmentAliasesOptional1700000000046');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000047, 'AddExternalIdentities1700000000047');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000048, 'AddIdentityEntitlementMappings1700000000048');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000049, 'AddRoleSourceOwnership1700000000049');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000050, 'MakeRoleKeysTenantScoped1700000000050');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000051, 'AddEngineConfigOwnershipAndRuntimeScope1700000000051');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000052, 'AddSsoProviderConfigOwnership1700000000052');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000053, 'AddIdentityMappingSourceRef1700000000053');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000054, 'AddRuntimeResourceSets1700000000054');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000055, 'AddRuntimeResourceInventory1700000000055');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000056, 'AddIdentityProviders1700000000056');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000057, 'AddIdentityReconciliationAndDeploymentReceipts1700000000057');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000058, 'AddDeploymentHistoryLineage1700000000058');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000059, 'AddEngineMetadataDiscoverySetting1700000000059');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000060, 'AddEnginePipelineReceiptSetting1700000000060');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000061, 'AddConfigBundleApplyRuns1700000000061');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000062, 'AddConfigBundleIdentityReplayTasks1700000000062');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000063, 'AddRefreshTokenProviderLineage1700000000063');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000064, 'AddSamlAssertionReplays1700000000064');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000065, 'UpgradeLegacySamlSignatures1700000000065');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000066, 'AddConfigOwnershipDrift1700000000066');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000067, 'AddEngineSetConfigOwnership1700000000067');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000068, 'AddProjectEngineTargetConfigOwnership1700000000068');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000069, 'AddRoleAssignmentConfigOwnership1700000000069');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000070, 'AddConfigRoleAssignmentOverrides1700000000070');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000071, 'AddConfigBundleApiVersion1700000000071');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000072, 'AddRuntimeResourceSetConfigProvenance1700000000072');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000073, 'AddIdentityConfigProvenance1700000000073');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000074, 'AddEngineReconciliationSchedule1700000000074');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000075, 'AddEngineDeploymentDiscoverySetting1700000000075');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000076, 'AddCredentiallessCustomerSidecarPolicy1700000000076');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000077, 'AddIdentityProviderKeyIdentity1700000000077');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000078, 'AddAuthzGroupKeyIdentity1700000000078');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000079, 'AddManagedResourceKeyIdentities1700000000079');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000080, 'AddIdentityMappingConfigKeyIdentity1700000000080');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000081, 'BackfillSsoAssignmentSourceMapping1700000000081');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000082, 'BackfillLegacyExternalIdentities1700000000082');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000083, 'AddUserAuthSessionVersion1700000000083');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000084, 'RequireCanonicalRoleAssignmentShape1700000000084');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000085, 'AddConfigBundleReplaySyncRun1700000000085');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000085, 'AddRoleAssignmentSourceRefIndex1700000000085');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000086, 'AddConfigBundleRuntimeReconciliationTasks1700000000086');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000087, 'AddSsoBroadEntitlementMappingSetting1700000000087');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000088, 'AddRuntimeResourceSetOwnershipMode1700000000088');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000089, 'DropLegacySsoMappingTables1700000000089');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000090, 'DropLegacySsoProviders1700000000090');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000091, 'FinalizeLegacyRoleAssignmentProjections1700000000091');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000092, 'DropLegacyUserIdentityColumns1700000000092');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000093, 'DropRoleAssignmentSourceMappingAlias1700000000093');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000094, 'DropRoleAssignmentResourceAliases1700000000094');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000095, 'DropRoleAssignmentUserAlias1700000000095');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000096, 'AddEngineTenancyFoundation1700000000096');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000097, 'AddEngineTenantMappingReference1700000000097');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000098, 'AddCamundaNativeGrantImportRuns1700000000098');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000099, 'AddCamundaNativeGrantRollbackReceipt1700000000099');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000100, 'WidenCamundaNativeGrantEvidence1700000000100');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000101, 'AddEngineBackstopFoundation1700000000101');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000102, 'AddEngineBackstopDriftObservations1700000000102');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000103, 'AddEngineBackstopConfigSecretReference1700000000103');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000104, 'AddIdentityMappingOwnershipMode1700000000104');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000105, 'AddPlatformGovernanceSettingsOwnership1700000000105');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000106, 'AddLoginExperienceMetadata1700000000106');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000107, 'ConsolidateLoginProviderPreference1700000000107');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000108, 'AddExternalEngineRegistrationIdentities1700000000108');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000109, 'RequireProjectTenantOwnership1700000000109');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000110, 'AddHeadlessPlatformSettingsOwnership1700000000110');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000111, 'AddIdentityProvisioningFoundation1700000000111');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000112, 'AddFederatedSessionLineage1700000000112');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000113, 'AddProvisioningCredentialIdempotency1700000000113');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000114, 'AddPluginPlatform1700000000114');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000115, 'AddPluginBrokerReplay1700000000115');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000116, 'AddPluginStorage1700000000116');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000117, 'AddPluginEvents1700000000117');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000118, 'AddPluginNotificationsAndSchedules1700000000118');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000119, 'AddPluginEmergencyControl1700000000119');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000120, 'AddPluginGatewayAdmission1700000000120');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000121, 'AddPluginEventCircuit1700000000121');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000122, 'AddPluginContributionAvailability1700000000122');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000123, 'AddPluginManager1700000000123');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000124, 'AddNativeSaasTenancy1700000000124');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000125, 'BackfillNativeTenantOwnership1700000000125');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000126, 'AddPostgresTenantRls1700000000126');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000127, 'AddTenantWorkloadLifecycle1700000000127');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000128, 'AddTenantApplicationMarketplace1700000000128');
INSERT INTO main.migrations ("timestamp", name) VALUES (1700000000129, 'AddTenantPluginEligibility1700000000129');

COMMIT;
