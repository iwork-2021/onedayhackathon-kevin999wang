//
//  MyAlbumApp.swift
//  MyAlbum
//
//  Created by kw9w on 12/21/21.
//

import SwiftUI

@main
struct MyAlbumApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
