//
//  ArisenVaultSignatureProvider.swift
//  ArisenSwiftVaultSignatureProvider
//
//  Created by Todd Bowden on 4/9/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import ArisenSwift
import ArisenSwiftVault

/// Signature provider implementation for Arisen SDK for Swift using Keychain and/or Secure Enclave.
public final class ArisenVaultSignatureProvider: ArisenSignatureProviderProtocol {

    private let vault: ArisenVault

    /// Require biometric identification for all signatures even if the key does not require it. Defaults to `false`.
    public var requireBio = false

    /// Init an instance of ArisenVaultSignatureProvider.
    ///
    /// - Parameters:
    ///     - accessGroup: The access group to create an instance of ArisenVault.
    ///     - requireBio: Require biometric identification for all signatures even if the key does not require it. Defaults to `false`.
    public init(accessGroup: String, requireBio: Bool = false) {
        vault = ArisenVault(accessGroup: accessGroup)
        self.requireBio = requireBio
    }

    /// Sign a transaction using an instance of ArisenVault with the specified accessGroup.
    ///
    /// - Parameters:
    ///   - request: The transaction signature request.
    ///   - completion: The transaction signature response.
    public func signTransaction(request: ArisenTransactionSignatureRequest, completion: @escaping (ArisenTransactionSignatureResponse) -> Void) {
        var response = ArisenTransactionSignatureResponse()

        guard let chainIdData = try? Data(hex: request.chainId) else {
            response.error = ArisenError(.signatureProviderError, reason: "\(request.chainId) is not a valid chain id")
            return completion(response)
        }
        let zeros = Data(repeating: 0, count: 32)
        let message = chainIdData + request.serializedTransaction + zeros
        sign(message: message, publicKeys: request.publicKeys) { (signatures, error) in
            guard let signatures = signatures else {
                response.error = error
                return completion(response)
            }
            guard signatures.count > 0 else {
                response.error = ArisenError(.signatureProviderError, reason: "No signatures")
                return completion(response)
            }
            var signedTransaction = ArisenTransactionSignatureResponse.SignedTransaction()
            signedTransaction.signatures = signatures
            signedTransaction.serializedTransaction = request.serializedTransaction
            response.signedTransaction = signedTransaction
            completion(response)
        }

    }

    /// Recursive function to sign a message with public keys. If there are multiple keys, the function will sign with the first and call itself with the remaining keys.
    private func sign(message: Data, publicKeys: [String], completion: @escaping ([String]?, ArisenError?) -> Void) {
        guard let firstPublicKey = publicKeys.first else {
            return completion([String](), nil)
        }
        vault.sign(message: message, ArisenPublicKey: firstPublicKey, requireBio: requireBio) { [weak self] (signature, error) in
            guard let signature = signature else {
                return completion(nil, error)
            }
            var remainingPublicKeys = publicKeys
            remainingPublicKeys.removeFirst()

            if remainingPublicKeys.count == 0 {
                return completion([signature], nil)
            }
            guard let strongSelf = self else {
                return completion(nil, ArisenError(.unexpectedError, reason: "self does not exist"))
            }
            strongSelf.sign(message: message, publicKeys: remainingPublicKeys, completion: { (signatures, error) in
                guard let signatures = signatures else {
                    return completion(nil, error)
                }
                completion([signature] + signatures, nil)
            })
        }
    }

    /// Get all available Arisen keys for the instance of ArisenVault with the specified accessGroup.
    ///
    /// - Parameters:
    ///     - completion: The available keys response.
    public func getAvailableKeys(completion: @escaping (ArisenAvailableKeysResponse) -> Void) {
        var response = ArisenAvailableKeysResponse()
        do {
            let vaultKeys = try vault.getAllVaultKeys()
            response.keys = vaultKeys.compactMap({ (vaultKey) -> String? in
                return vaultKey.ArisenPublicKey
            })
            completion(response)
        } catch {
            response.error = error.ArisenError
            completion(response)
        }
    }
}
