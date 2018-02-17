//
//  ViewController.swift
//  BitcoinPriceTracker
//
//  Created by Nathan Pabrai on 2/16/18.
//  Copyright © 2018 Nathan Pabrai. All rights reserved.
//

import SwiftyJSON
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var priceLabel: UILabel!
    @IBAction func refreshTapped(_ sender: Any) {
        //Handle tap
        queryUpdateCurrentValue()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        priceLabel.layer.borderColor = UIColor.black.cgColor
        priceLabel.layer.borderWidth = 1
        priceLabel.layer.cornerRadius = 8

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateCurrentValue(from bitcoinJSONResults: JSON) {
        
        print(bitcoinJSONResults)
        
        let bpi = bitcoinJSONResults["bpi"]
        let currencySymbol = "USD"
        let currency = bpi[currencySymbol ?? ""]
        var rawRate = currency["rate"] .rawString() ?? "0"
        let rate = Double(rawRate.replacingOccurrences(of: ",", with: "")) ?? 0
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.priceLabel.text = "\(currencySymbol) \(rate)"
        })
    }
    
    
    func queryUpdateCurrentValue() {
        queryCurrentValue { (resultsJSON) in
            self.updateCurrentValue(from: resultsJSON)
        }
    }
    
    func queryCurrentValue(_ completion: @escaping (JSON) -> Void) {
        
        let queryLink = "https://api.coindesk.com/v1/bpi/currentprice.json"
        
        
        // Fetch new data
        fetchUrl(queryLink) { (result) in
            
            do {
                
                let bitcoinResults = try result()
                
                let bitcoinJSONResults = try JSON(data: bitcoinResults)
                
                completion(bitcoinJSONResults)
                
            } catch {
                //TO-DO: Alert users no data found
            }
        }
    }
    
    func fetchUrl(_ urlString: String, completionHandler: @escaping (_ result: () throws -> Data) -> Void) -> Void {
        
        if let queryUrl: URL = URL(string: urlString) {
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: queryUrl, completionHandler: { (queryData, response, error) -> Void in
                
                guard error == nil else { return completionHandler({throw Errors.requestError}) }
                
                guard queryData != nil, let queryData = queryData else {
                    return completionHandler({throw Errors.noDataError})
                }
                
                return completionHandler({ queryData })
            })
            task.resume()
        }
    }
    
    enum Errors:Error {
        case requestError
        case noDataError
    }
}

