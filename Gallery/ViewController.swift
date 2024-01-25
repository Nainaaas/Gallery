//
//  ViewController.swift
//  Gallery
//
//  Created by Shahina Kassim on 11/12/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var AddImage: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    var album =  [URL]()
   // var album = [UIImage(named: "image1"), UIImage(named: "image2")]
    var deleteArray = [URL]()
    var isEdit = false
    @IBOutlet weak var Edit: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
fetchAllImages()
       
        updateUI()
    }
    func updateUI(){
        if isEdit{
            Edit.title = Constants.cancel
            AddImage.title = Constants.delete
            if deleteArray.isEmpty{
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            else{
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
        }else{
            navigationItem.rightBarButtonItem?.isEnabled = true
            Edit.title = Constants.edit
            AddImage.title = Constants.AddImage
        }
        if( album.isEmpty){
         //   navigationItem.leftBarButtonItem?.isEnabled = false
        }else{
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    @IBAction func Edit(_ sender: Any) {
        if isEdit{ // cancel button action
            deleteArray.removeAll()
        }
        isEdit = !isEdit
        updateUI()
        self.collectionView.reloadData()
       
       
    }
    func deleteFromDirectory(){
        for url in deleteArray{
            do{
                if FileManager.default.fileExists(atPath: url.path){
                   try FileManager.default.removeItem(atPath: url.path)
                    album.removeAll { $0 == url }
                    deleteArray.removeAll { $0 == url }
                }

            }catch{
                print("Deleting elements coudnt complete")
            }
        }
    }
    @IBAction func AddImage(_ sender: Any) {
        if isEdit{
            isEdit = !isEdit
           
          //  deleteFromDirectory()
            collectionView.reloadData()
        }
        else{
            let pickerView = UIImagePickerController()
            pickerView.delegate = self
            pickerView.sourceType = .camera
            pickerView.allowsEditing = true
            self.present(pickerView, animated: true)
        }
        updateUI()
    }
    func saveImage(image: UIImage) {
        let imageName = UUID().uuidString
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask).first!
        let url = documentDirectory.appendingPathComponent("GalleryApp").appendingPathComponent(imageName).appendingPathExtension(".png")
        if !FileManager.default.fileExists(atPath: url.path){
            do{
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
               try image.pngData()?.write(to: url)
            }catch{
                print("Coudnt save to the file :\(error)")
            }
        }else{
            print("File is alredy is exist")
        }
       
    }
    func fetchAllImages() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask).first!
        let imageFolderPath = documentDirectory.appendingPathComponent("GalleryApp")

        do{
            let imageURls = try FileManager.default.contentsOfDirectory(at: imageFolderPath, includingPropertiesForKeys: nil)
            self.album = imageURls
        }catch{
            print("Error occured while reading from the directory:\(error)")
        }
    }

}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
    //    cell.photo.image = album[indexPath.row]
        
        cell.configureCell(imageURL: album[indexPath.item], indexItem: indexPath.item, isEditing: isEdit, isSelectedForDelete: deleteArray.contains(album[indexPath.item]))
        cell.delegate = self
        // Load image from file path and set it to the UIImageView in your cell
       
        return cell
    }
    
    
}
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            saveImage(image: image)
        }
     
        collectionView.reloadData()
    }
    
}

extension ViewController: DeleteDelegate{
    func deleteAction(index: Int) {
        if deleteArray.contains(album[index]){
            deleteArray.removeAll { $0 == album[index] }
        }else{
            deleteArray.append(album[index])
        }
        updateUI()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

    }

}
