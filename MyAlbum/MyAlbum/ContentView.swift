//
//  ContentView.swift
//  MyAlbum
//
//  Created by kw9w on 12/21/21.
//

import SwiftUI
import CoreData


struct CameraView: View {
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
