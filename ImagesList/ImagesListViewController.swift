//
//  ImagesListViewController.swift
//  Imagegram
//
//  Created by Владислав Усачев on 04.04.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName:[String] = Array(0..<20).map{"\($0)"}
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = NSLocale(localeIdentifier: "ru_Ru") as Locale
        return formatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == showSingleImageSegueIdentifier { // 1
               guard
                   let viewController = segue.destination as? SingleViewController, // 2
                   let indexPath = sender as? IndexPath // 3
               else {
                   assertionFailure("Invalid segue destination") // 4
                   return
               }

               let image = UIImage(named: photosName[indexPath.row]) // 5
               viewController.image = image // 6
           } else {
               super.prepare(for: segue, sender: sender) // 7
           }
       }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row] //Получаем имя
        guard let image = UIImage(named: imageName) else {return}//Проверяем возможность создать такой UIImage
        cell.cellImage.image = image
        
        let currientDate = Date()
        let dateString = dateFormatter.string(from: currientDate)
        cell.dataLabel.text = dateString
        
        if indexPath.row % 2 == 0{
            cell.likeButton.tintColor = .ypRed
        } else {
            cell.likeButton.tintColor = .gray

        }
    }
}

extension ImagesListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        }
}

extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifire, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {return tableView.rowHeight}
        let imageViewHeight = tableView.bounds.width / image.size.width * image.size.height
        let totalCellHeight = imageViewHeight 
        return totalCellHeight
    }
}
