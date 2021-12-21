//
//  ContentView.swift
//  MyAlbum
//
//  Created by kw9w on 12/21/21.
//

import SwiftUI
import CoreData


struct CameraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let classfier = ClassifyKindsOfPic()
    
    @State private var showCameraPicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    //这里的image用于放置等会拍摄了的照片
    @State private var image: UIImage = UIImage()
    // the result of classify
    @State private var result: String = "waiting..."
    
    @State private var confidence: String = ""
    @State private var identifier: String = ""
    
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
                Text("photo")
            })
            
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(self.result)
        }
        .sheet(isPresented: $showCameraPicker,
               content: {
            ImagePicker(sourceType: self.sourceType) { image in
                self.image = image
                (self.identifier, self.confidence) = self.classfier.classify(image: image)
                self.result = self.identifier + " : " + self.confidence
                self.addItem(classfier: self.identifier, image: image)
            }
        })
    }
    
    private func addItem(classfier: String, image: UIImage) {
        
        let newItem = PictureItem(context: viewContext)
        newItem.timestamp = Date()
        newItem.classifier = classfier
        newItem.pic = image.pngData()
        
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

struct KindsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PictureItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<PictureItem>
    
    @State private var searchTerm = ""
    
    var searchQuery: Binding<String> {
      Binding {
        // 1
        searchTerm
      } set: { newValue in
        // 2
        searchTerm = newValue
        
        // 3
        guard !newValue.isEmpty else {
          items.nsPredicate = nil
          return
        }

        // 4
        items.nsPredicate = NSPredicate(
          format: "name contains[cd] %@",
          newValue)
      }
    }

    
    var body: some View {
        Button(action: {
            
        }, label: {
            Text("Camera")
        })
    }
    
    
}

struct AllView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PictureItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<PictureItem>
    
    @State private var showingPopover = false
    
    var body: some View{
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 3) {
                    ForEach(items) { item in
                        let img = UIImage(data: item.pic!)!
                        CardView(image: img)
                            .onTapGesture {
                                self.showingPopover = true
                            }
                            .sheet(isPresented: $showingPopover, content: {
                                VStack {
                                    Text("as")
                                    
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 340, height: 600)
                                        .clipped()
                                        .cornerRadius(9)
                                      
                                }
                            })
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("ALL")
        }
    }
}

struct CardView: View {
    let image: UIImage
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 110)
                .clipped()
                .cornerRadius(9)
        }
        .frame(width: 110, height: 110)
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PictureItem.timestamp, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<PictureItem>
    
    var body: some View {
        TabView {
            CameraView()
                .environment(\.managedObjectContext, self.viewContext)
                .tabItem({
                    Image(systemName: "camera.circle")
                    Text("camera")
                })
            AllView()
                .tabItem({
                    Image(systemName: "photo.on.rectangle")
                    Text("all")
                })
            KindsView()
                .environment(\.managedObjectContext, self.viewContext)
                .tabItem({
                    Image(systemName: "photo.circle")
                    Text("kinds")
                })
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
