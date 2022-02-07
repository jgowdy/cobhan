package main

import (
	"C"
)
import (
	"context"
	"godaddy.com/cobhan"

	"github.com/aws/aws-sdk-go/aws"
	awssession "github.com/aws/aws-sdk-go/aws/session"
	"github.com/godaddy/asherah/go/appencryption"
	"github.com/godaddy/asherah/go/appencryption/pkg/crypto/aead"
	"github.com/godaddy/asherah/go/appencryption/pkg/kms"
	"github.com/godaddy/asherah/go/appencryption/pkg/persistence"
	"github.com/godaddy/asherah/go/securememory/memguard"
	"unsafe"
)

const ERR_GET_SESSION_FAILED = -100
const ERR_ENCRYPT_FAILED = -101
const ERR_DECRYPT_FAILED = -102

func main() {
}

var globalSessionFactory *appencryption.SessionFactory
var globalCtx context.Context
var globalSession *appencryption.Session

//TODO: Move this to an exported initialize function that takes these values by parameter
func init() {
	options := &Options{}
	options.KMS = "static"
	options.ServiceName = "TestService"
	options.ProductID = "TestProduct"
	options.Verbose = true
	options.EnableSessionCaching = true

	crypto := aead.NewAES256GCM()

	globalSessionFactory = appencryption.NewSessionFactory(
		&appencryption.Config{
			Service: options.ServiceName,
			Product: options.ProductID,
			Policy:  NewCryptoPolicy(options),
		},
		NewMetastore(options),
		NewKMS(options, crypto),
		crypto,
		appencryption.WithSecretFactory(new(memguard.SecretFactory)),
		appencryption.WithMetrics(false),
	)
}

func NewMetastore(opts *Options) appencryption.Metastore {
	switch opts.Metastore {
	case "rdbms":
		// TODO: support other databases
		db, err := newMysql(opts.ConnectionString)
		if err != nil {
			panic(err)
		}

		// set optional replica read consistency
		if len(opts.ReplicaReadConsistency) > 0 {
			err := setRdbmsReplicaReadConsistencyValue(opts.ReplicaReadConsistency)
			if err != nil {
				panic(err)
			}
		}

		return persistence.NewSQLMetastore(db)
	case "dynamodb":
		awsOpts := awssession.Options{
			SharedConfigState: awssession.SharedConfigEnable,
		}

		if len(opts.DynamoDBEndpoint) > 0 {
			awsOpts.Config.Endpoint = aws.String(opts.DynamoDBEndpoint)
		}

		if len(opts.DynamoDBRegion) > 0 {
			awsOpts.Config.Region = aws.String(opts.DynamoDBRegion)
		}

		return persistence.NewDynamoDBMetastore(
			awssession.Must(awssession.NewSessionWithOptions(awsOpts)),
			persistence.WithDynamoDBRegionSuffix(opts.EnableRegionSuffix),
			persistence.WithTableName(opts.DynamoDBTableName),
		)
	default:
		return persistence.NewMemoryMetastore()
	}
}

func NewKMS(opts *Options, crypto appencryption.AEAD) appencryption.KeyManagementService {
	if opts.KMS == "static" {
		m, err := kms.NewStatic("thisIsAStaticMasterKeyForTesting", aead.NewAES256GCM())
		if err != nil {
			panic(err)
		}

		return m
	}

	m, err := kms.NewAWS(crypto, opts.PreferredRegion, opts.RegionMap)
	if err != nil {
		panic(err)
	}

	return m
}

//export Decrypt
func Decrypt(partitionIdPtr unsafe.Pointer, encryptedDataPtr unsafe.Pointer, encryptedKeyPtr unsafe.Pointer, created int64, parentKeyIdPtr unsafe.Pointer, parentKeyCreated int64, outputDecryptedDataPtr unsafe.Pointer) int32 {
	DebugOutput("Decrypt()")
	partitionId, result := cobhan.BufferToString(partitionIdPtr)
	if result != 0 {
		return result
	}

	DebugOutput("Decrypting with partition: " + partitionId)

	encryptedData, result := cobhan.BufferToBytes(encryptedDataPtr)
	if result != 0 {
		return result
	}

	//DebugOutput("encryptedData length: " + string(len(encryptedData)))

	encryptedKey, result := cobhan.BufferToBytes(encryptedKeyPtr)
	if result != 0 {
		return result
	}

	//DebugOutput("encryptedKey length: " + string(len(encryptedKey)))

	parentKeyId, result := cobhan.BufferToString(parentKeyIdPtr)
	if result != 0 {
		return result
	}

	DebugOutput("parentKeyId: " + parentKeyId)

	session, err := globalSessionFactory.GetSession(partitionId)
	if err != nil {
		DebugOutput(err.Error())
		return ERR_GET_SESSION_FAILED
	}

	drr := &appencryption.DataRowRecord{
		Data: encryptedData,
		Key: &appencryption.EnvelopeKeyRecord{
			EncryptedKey: encryptedKey,
			Created:      created,
			ParentKeyMeta: &appencryption.KeyMeta{
				ID:      parentKeyId,
				Created: parentKeyCreated,
			},
		},
	}

	var ctx context.Context
	data, err := session.Decrypt(ctx, *drr)
	if err != nil {
		DebugOutput("Decrypt failed: " + err.Error())
		return ERR_DECRYPT_FAILED
	}

	return cobhan.BytesToBuffer(data, outputDecryptedDataPtr)
}

//export Encrypt
func Encrypt(partitionIdPtr unsafe.Pointer, dataPtr unsafe.Pointer, outputEncryptedDataPtr unsafe.Pointer, outputEncryptedKeyPtr unsafe.Pointer, outputCreatedPtr unsafe.Pointer, outputParentKeyIdPtr unsafe.Pointer, outputParentKeyCreatedPtr unsafe.Pointer) int32 {
	DebugOutput("Encrypt()")

	partitionId, result := cobhan.BufferToString(partitionIdPtr)
	if result != 0 {
		return result
	}

	DebugOutput("Encrypting with partition: " + partitionId)

	data, result := cobhan.BufferToBytes(dataPtr)
	if result != 0 {
		return result
	}

	//DebugOutput("Encrypting with data length: " + string(len(data)))

	session, err := globalSessionFactory.GetSession(partitionId)
	if err != nil {
		DebugOutput(err.Error())
		return ERR_GET_SESSION_FAILED
	}

	var ctx context.Context
	drr, err := session.Encrypt(ctx, data)
	if err != nil {
		DebugOutput("Encrypt failed: " + err.Error())
		return ERR_ENCRYPT_FAILED
	}

	result = cobhan.BytesToBuffer(drr.Data, outputEncryptedDataPtr)
	if result != 0 {
		return result
	}

	//DebugOutput("Encrypting with output encrypted data length: " + string(len(drr.Data)))

	result = cobhan.BytesToBuffer(drr.Key.EncryptedKey, outputEncryptedKeyPtr)
	if result != 0 {
		return result
	}

	//DebugOutput("Encrypting with output encrypted key length: " + string(len(drr.Key.EncryptedKey)))

	cobhan.Int64ToBuffer(drr.Key.Created, outputCreatedPtr)

	result = cobhan.StringToBuffer(drr.Key.ParentKeyMeta.ID, outputParentKeyIdPtr)
	if result != 0 {
		return result
	}

	DebugOutput("Encrypting with parent key ID: " + drr.Key.ParentKeyMeta.ID)

	cobhan.Int64ToBuffer(drr.Key.ParentKeyMeta.Created, outputParentKeyCreatedPtr)

	return 0
}

func NewCryptoPolicy(options *Options) *appencryption.CryptoPolicy {
	policyOpts := []appencryption.PolicyOption{
		appencryption.WithExpireAfterDuration(options.ExpireAfter),
		appencryption.WithRevokeCheckInterval(options.CheckInterval),
	}

	if options.EnableSessionCaching {
		policyOpts = append(policyOpts,
			appencryption.WithSessionCache(),
			appencryption.WithSessionCacheMaxSize(options.SessionCacheMaxSize),
			appencryption.WithSessionCacheDuration(options.SessionCacheDuration),
		)
	}

	return appencryption.NewCryptoPolicy(policyOpts...)
}
