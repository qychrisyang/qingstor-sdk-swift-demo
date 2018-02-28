//
//  BucketListController.swift
//  QingStorSDKDemo
//
//  Created by Chris on 16/12/29.
//  Copyright © 2016年 Yunify. All rights reserved.
//

import UIKit
import QingStorSDK

class BucketListController: UITableViewController {
    
    fileprivate var qsService: QingStor!
    
    fileprivate var listBucketsOutput: ListBucketsOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qsService = QingStor()
        
        setupView()
    }

    func setupView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let refresh = UIRefreshControl()
        refresh.tintColor = .gray
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        refreshControl = refresh
        beginRefresh()
    }
    
    private func beginRefresh() {
        if !refreshControl!.isRefreshing {
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl!.frame.size.height - 64)
            }, completion: { finished in
                self.refreshControl?.beginRefreshing()
                self.refreshControl?.sendActions(for: .valueChanged)
            })
        }
    }
    
    @objc private func handleRefresh() {
        requestBucketList()
    }
    
    private func requestBucketList() {
        qsService.listBuckets(input: ListBucketsInput()) { response, error in
            if let response = response {
                if response.output.errMessage == nil {
                    self.listBucketsOutput = response.output
                    self.tableView.reloadData()
                } else {
                    print("error: \(String(describing: response.output.errMessage))")
                }
            } else {
                print("error: \(String(describing: error))")
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listBucketsOutput?.count ?? 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BucketCell", for: indexPath) as? BucketTableViewCell else { return UITableViewCell() }
        
        let bucket = listBucketsOutput?.buckets?[indexPath.row]
        cell.textLabel?.text = bucket?.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "ShowObjectList", sender: listBucketsOutput?.buckets?[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ObjectListController, let bucketModel = sender as? BucketModel, segue.identifier == "ShowObjectList" {
            destination.bucketModel = bucketModel
        }
    }
}

class BucketTableViewCell: UITableViewCell {

}
