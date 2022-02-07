import path from 'path'
import cobhan from 'cobhan'

// KeyMeta contains the ID and Created timestamp for an encryption key.

/**
 * @typedef {Object} KeyMeta
 * @property {string} ID
 * @property {number} Created
 */

// DataRowRecord contains the encrypted key and provided data, as well as the information
// required to decrypt the key encryption key. This struct should be stored in your
// data persistence as it's required to decrypt data.

/**
 * @typedef {Object} DataRowRecord
 * @property {EnvelopeKeyRecord} Key
 * @property {Buffer} Data
 */

// EnvelopeKeyRecord represents an encrypted key and is the data structure used
// to persist the key in our key table. It also contains the meta data
// of the key used to encrypt it.

/**
 * @typedef {Object} EnvelopeKeyRecord
 * @property {number} Created
 * @property {Buffer} EncryptedKey
 * @property {KeyMeta} ParentKeyMeta
 */

  const libasherah = cobhan.load_platform_library('node_modules/asherah/binaries', 'libasherah', {
    'Encrypt': ['int32', ['pointer', 'pointer', 'pointer', 'pointer', 'pointer', 'pointer', 'pointer']],
    'Decrypt': ['int32', ['pointer', 'pointer', 'pointer', 'int64', 'pointer', 'int64', 'pointer']],
    });

/**
* @param {string} partitionId
* @param {DataRowRecord} dataRowRecord
* @return {Buffer}
*/
function decrypt(partitionId, dataRowRecord) {
    const partitionIdBuffer = cobhan.string_to_cbuffer(partitionId);
    const encryptedDataBuffer = cobhan.buffer_to_cbuffer(dataRowRecord['Data']);
    const encryptedKeyBuffer = cobhan.buffer_to_cbuffer(dataRowRecord['Key']['EncryptedKey']);
    const created = dataRowRecord['Key']['Created'];
    const parentKeyIdBuffer = cobhan.string_to_cbuffer(dataRowRecord['Key']['ParentKeyMeta']['ID']);
    const parentKeyCreated = dataRowRecord['Key']['ParentKeyMeta']['Created'];

    const outputDataBuffer = cobhan.allocate_cbuffer(encryptedDataBuffer.length + 256);

    const result = libasherah.Decrypt(partitionIdBuffer, encryptedDataBuffer, encryptedKeyBuffer, created, parentKeyIdBuffer, parentKeyCreated, outputDataBuffer);
    if (result < 0) {
        throw new Error('decrypt failed: ' + result);
    }

    return cobhan.cbuffer_to_buffer(outputDataBuffer);
}

/**
* @param {string} partitionId
* @param {Buffer} data
* @return {DataRowRecord}
*/
function encrypt(partitionId, data) {
    const partitionIdBuffer = cobhan.string_to_cbuffer(partitionId);
    const dataBuffer = cobhan.buffer_to_cbuffer(data);
    const outputEncryptedDataBuffer = cobhan.allocate_cbuffer(data.length + 256);
    const outputEncryptedKeyBuffer = cobhan.allocate_cbuffer(256);
    const outputCreatedBuffer = cobhan.int64_to_buffer(0);
    const outputParentKeyIdBuffer = cobhan.allocate_cbuffer(256);
    const outputParentKeyCreatedBuffer = cobhan.int64_to_buffer(0);

    const result = libasherah.Encrypt(partitionIdBuffer, dataBuffer, outputEncryptedDataBuffer, outputEncryptedKeyBuffer,
        outputCreatedBuffer, outputParentKeyIdBuffer, outputParentKeyCreatedBuffer);

    if (result < 0) {
        throw new Error('encrypt failed: ' + result);
    }
    const parentKeyId = cobhan.cbuffer_to_string(outputParentKeyIdBuffer);
    console.log("Encrypt returned parent key ID: " + parentKeyId);
    const dataRowRecord = {
        Data: cobhan.cbuffer_to_buffer(outputEncryptedDataBuffer),
        Key: {
            EncryptedKey: cobhan.cbuffer_to_buffer(outputEncryptedKeyBuffer),
            Created: cobhan.buffer_to_int64(outputCreatedBuffer),
            ParentKeyMeta: {
                ID: parentKeyId,
                Created: cobhan.buffer_to_int64(outputParentKeyCreatedBuffer)
            }
        }
    };

    return dataRowRecord;
}

export default { encrypt, decrypt };
