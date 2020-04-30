//
//  UpdateCredentialsFlowView.swift
//  PermanentUserProviderSelection
//
//  Created by Menghao Zhang on 2020-04-30.
//  Copyright © 2020 Tink. All rights reserved.
//

import SwiftUI
import TinkLink

struct UpdateCredentialsFlowView: View, UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler

    private let provider: Provider
    private let credentials: Credentials
    private let credentialsController: CredentialsController

    init(provider: Provider, credentials: Credentials, credentialsController: CredentialsController, onCompletion: @escaping CompletionHandler) {
        self.onCompletion = onCompletion
        self.provider = provider
        self.credentials = credentials
        self.credentialsController = credentialsController
    }

    class Coordinator {
        let completionHandler: CompletionHandler

        init(completionHandler: @escaping CompletionHandler) {
            self.completionHandler = completionHandler
        }
    }

    func makeCoordinator() -> UpdateCredentialsFlowView.Coordinator {
        return Coordinator(completionHandler: onCompletion)
    }

    func makeUIViewController(context: Context) -> UpdateCredentialsFlowView.UIViewControllerType {
        let credentialsContext = credentialsController.credentialsContext
        let viewController = UpdateCredentialsViewController(provider: provider, credentials: credentials, credentialsContext: credentialsContext)
        viewController.onCompletion = context.coordinator.completionHandler
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UpdateCredentialsFlowView.UIViewControllerType, context: Context) {
        // NOOP
    }
}
