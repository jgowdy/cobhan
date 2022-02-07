package main

import (
	"C"
)
import (
	"context"

	"godaddy.com/appencryption"
	"godaddy.com/appencryption/pkg/crypto/aead"
	"godaddy.com/appencryption/pkg/kms"
	"godaddy.com/appencryption/pkg/persistence"
	"godaddy.com/securememory/protectedmemory"
)

func main() {
	secureMemoryTest()
	asherahTest()
}

// Sample library exports for client testing
func init() {
	//rand.Seed(time.Now().UnixNano())
}

//export secureMemoryTest
func secureMemoryTest() {
	secretFactory := new(protectedmemory.SecretFactory)
	secret, err := secretFactory.CreateRandom(1)
	if err != nil {
		panic(err)
	}

	defer secret.Close()
}

//export asherahTest
func asherahTest() {
	crypto := aead.NewAES256GCM()
	config := &appencryption.Config{
		Service: "reference_app",
		Product: "productId",
		Policy:  appencryption.NewCryptoPolicy(),
	}
	metastore := persistence.NewMemoryMetastore()
	key, err := kms.NewStatic("thisIsAStaticMasterKeyForTesting", crypto)
	if err != nil {
		panic(err)
	}

	// Create a session factory. The builder steps used below are for testing only.
	factory := appencryption.NewSessionFactory(config, metastore, key, crypto)
	defer factory.Close()

	// Now create a cryptographic session for a partition.
	sess, err := factory.GetSession("shopper123")
	if err != nil {
		panic(err)
	}
	// Close frees the memory held by the intermediate keys used in this session
	defer sess.Close()

	// Now encrypt some data
	dataRow, err := sess.Encrypt(context.Background(), []byte("mysupersecretpayload"))
	if err != nil {
		panic(err)
	}

	//Decrypt the data
	data, err := sess.Decrypt(context.Background(), *dataRow)
	if err != nil {
		panic(err)
	}

	if data[0] != 'm' {
		panic("failed")
	}
}
