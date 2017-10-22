/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

protocol ProductViewDelegate {
  func didTouch(productView: ProductView)
}


class ProductView: ARAnnotationView {
  var titleLabel: UILabel?
  var distanceLabel: UILabel?
  var imageLabel: UILabel?
  var delegate: ProductViewDelegate?
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    loadUI()
  }
  
  func loadUI() {
    titleLabel?.removeFromSuperview()
    distanceLabel?.removeFromSuperview()
    imageLabel?.removeFromSuperview()
    
    print("Creating label")
    let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
    label.font = UIFont.systemFont(ofSize: 16)
    label.numberOfLines = 0
    label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    label.textColor = UIColor.white
    self.addSubview(label)
    self.titleLabel = label
    
    distanceLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
    distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    distanceLabel?.textColor = UIColor.green
    distanceLabel?.font = UIFont.systemFont(ofSize: 12)
//    self.addSubview(distanceLabel!)
    
    imageLabel = UILabel(frame: CGRect(x: 50, y: 0, width: self.frame.size.width, height: 20))
    imageLabel?.numberOfLines = 0
    
    if let annotation = annotation as? Place {
      titleLabel?.text = annotation.placeName
      distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
      imageLabel?.text = annotation.placeName
      print("Title label text: " + (titleLabel?.text)!)
      print("Image label text: " + (imageLabel?.text)!)
    }
    
    imageLabel?.addImage(imageName: "icons8-Home-50.png")
    self.addSubview(imageLabel!)
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
    distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
    imageLabel?.frame = CGRect(x: 50, y: 0, width: self.frame.size.width, height: 30)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.didTouch(productView: self)
  }
}

extension UILabel
{
  func addImage(imageName: String)
  {
    print("Adding image")
    print("Image Name: " + imageName)
    let attachment:NSTextAttachment = NSTextAttachment()
    attachment.image = UIImage(named: imageName)
    let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
    let myString:NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
    myString.append(attachmentString)
    
    self.attributedText = myString
  }
}
