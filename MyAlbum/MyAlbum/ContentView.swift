//
//  ContentView.swift
//  MyAlbum
//
//  Created by kw9w on 12/21/21.
//

import SwiftUI
import CoreData


struct CameraView: View {
    @State private var showCameraPicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
       //这里的image用于放置等会拍摄了的照片
       @State private var image: UIImage = UIImage()
       var body: some View {
           List{
               Button(action: {
                   showCameraPicker = true
                   sourceType = .camera
               }, label: {
                   Text("Camera")
               })
               Button(action: {
                   showCameraPicker = true
                   sourceType = .photoLibrary
               }, label: {
                   Text("Photo")
               })
               
               
               Image(uiImage: image)
                   .resizable()
                   .aspectRatio(contentMode: .fit)
               
               Text("cate")
           }
           .sheet(isPresented: $showCameraPicker,
                  content: {
               ImagePicker(sourceType: self.sourceType) { image in
                   self.image = image
               }
           })
       }
}



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        TabView {
            CameraView()
                .tabItem({
                    Image(systemName: "camera.circle")
                    Text("camera")
                })
            Text("page two")
                .tabItem({
                    Image(systemName: "photo.on.rectangle")
                    Text("all")
                })
            Text("Page three")
                .tabItem({
                    Image(systemName: "photo.circle")
                    Text("kinds")
                })
        }
    }
    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//            Text("Select an item")
//        }
//    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
