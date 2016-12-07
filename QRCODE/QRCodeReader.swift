//
//  QRCodeReader.swift
//  QRCODE
//
//  Created by Riley Anderson.
//  Copyright © 2016 Riley Anderson. All rights reserved.
//

import Foundation
import GPUImage
import UIKit

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func blackWhite() -> UIImage? {
        guard let image: GPUImagePicture = GPUImagePicture(image: self) else {
            print("unable to create GPUImagePicture")
            return nil
        }
        let filter = GPUImageAverageLuminanceThresholdFilter()
        image.addTarget(filter)
        filter.useNextFrameForImageCapture()
        image.processImage()
        guard let processedImage: UIImage = filter.imageFromCurrentFramebuffer(with: UIImageOrientation.up) else {
            print("unable to obtain UIImage from filter")
            return nil
        }
        return processedImage
    }
}


class QRCodeReader
{
    private let black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    private let qrAlignment:[[Int]] = [[], [6, 18], [6, 22], [6, 26], [6, 30], [6, 34], [6, 22, 38], [6, 24, 42], [6, 26, 46], [6, 28, 50], [6, 30, 54], [6, 32, 58], [6, 34, 62], [6, 26, 46, 66], [6, 26, 48, 70], [6, 26, 50, 74], [6, 30, 54, 78], [6, 30, 56, 82], [6, 30, 58, 86], [6, 34, 62, 90], [6, 28, 50, 72, 94], [6, 26, 50, 74, 98], [6, 30, 54, 78, 102], [6, 28, 54, 80, 106], [6, 32, 58, 84, 110], [6, 30, 58, 86, 114], [6, 34, 62, 90, 118], [6, 26, 50, 74, 98, 122], [6, 30, 54, 78, 102, 126], [6, 26, 52, 78, 104, 130], [6, 30, 56, 82, 108, 134], [6, 34, 60, 86, 112, 138], [6, 30, 58, 86, 114, 142], [6, 34, 62, 90, 118, 146], [6, 30, 54, 78, 102, 126, 150], [6, 24, 50, 76, 102, 128, 154], [6, 28, 54, 80, 106, 132, 158], [6, 32, 58, 84, 110, 136, 162], [6, 26, 54, 82, 110, 138, 166], [6, 30, 58, 86, 114, 142, 170]]
    
    private let qrWordCount:[[[(Int,Int)]]] = [[[(1, 19)], [(1, 16)], [(1, 13)], [(1, 9)]], [[(1, 34)], [(1, 28)], [(1, 22)], [(1, 16)]], [[(1, 55)], [(1, 44)], [(2, 17)], [(2, 13)]], [[(1, 80)], [(2, 32)], [(2, 24)], [(4, 9)]], [[(1, 108)], [(2, 43)], [(2, 15), (2, 16)], [(2, 11), (2, 12)]], [[(2, 68)], [(4, 27)], [(4, 19)], [(4, 15)]], [[(2, 78)], [(4, 31)], [(2, 14), (4, 15)], [(4, 13), (1, 14)]], [[(2, 97)], [(2, 38), (2, 39)], [(4, 18), (2, 19)], [(4, 14), (2, 15)]], [[(2, 116)], [(3, 36), (2, 37)], [(4, 16), (4, 17)], [(4, 12), (4, 13)]], [[(2, 68), (2, 69)], [(4, 43), (1, 44)], [(6, 19), (2, 20)], [(6, 15), (2, 16)]], [[(4, 81)], [(1, 50), (4, 51)], [(4, 22), (4, 23)], [(3, 12), (8, 13)]], [[(2, 92), (2, 93)], [(6, 36), (2, 37)], [(4, 20), (6, 21)], [(7, 14), (4, 15)]], [[(4, 107)], [(8, 37), (1, 38)], [(8, 20), (4, 21)], [(12, 11), (4, 12)]], [[(3, 115), (1, 116)], [(4, 40), (5, 41)], [(11, 16), (5, 17)], [(11, 12), (5, 13)]], [[(5, 87), (1, 88)], [(5, 41), (5, 42)], [(5, 24), (7, 25)], [(11, 12), (7, 13)]], [[(5, 98), (1, 99)], [(7, 45), (3, 46)], [(15, 19), (2, 20)], [(3, 15), (13, 16)]], [[(1, 107), (5, 108)], [(10, 46), (1, 47)], [(1, 22), (15, 23)], [(2, 14), (17, 15)]], [[(5, 120), (1, 121)], [(9, 43), (4, 44)], [(17, 22), (1, 23)], [(2, 14), (19, 15)]], [[(3, 113), (4, 114)], [(3, 44), (11, 45)], [(17, 21), (4, 22)], [(9, 13), (16, 14)]], [[(3, 107), (5, 108)], [(3, 41), (13, 42)], [(15, 24), (5, 25)], [(15, 15), (10, 16)]], [[(4, 116), (4, 117)], [(17, 42)], [(17, 22), (6, 23)], [(19, 16), (6, 17)]], [[(2, 111), (7, 112)], [(17, 46)], [(7, 24), (16, 25)], [(34, 13)]], [[(4, 121), (5, 122)], [(4, 47), (14, 48)], [(11, 24), (14, 25)], [(16, 15), (14, 16)]], [[(6, 117), (4, 118)], [(6, 45), (14, 46)], [(11, 24), (16, 25)], [(30, 16), (2, 17)]], [[(8, 106), (4, 107)], [(8, 47), (13, 48)], [(7, 24), (22, 25)], [(22, 15), (13, 16)]], [[(10, 114), (2, 115)], [(19, 46), (4, 47)], [(28, 22), (6, 23)], [(33, 16), (4, 17)]], [[(8, 122), (4, 123)], [(22, 45), (3, 46)], [(8, 23), (26, 24)], [(12, 15), (28, 16)]], [[(3, 117), (10, 118)], [(3, 45), (23, 46)], [(4, 24), (31, 25)], [(11, 15), (31, 16)]], [[(7, 116), (7, 117)], [(21, 45), (7, 46)], [(1, 23), (37, 24)], [(19, 15), (26, 16)]], [[(5, 115), (10, 116)], [(19, 47), (10, 48)], [(15, 24), (25, 25)], [(23, 15), (25, 16)]], [[(13, 115), (3, 116)], [(2, 46), (29, 47)], [(42, 24), (1, 25)], [(23, 15), (28, 16)]], [[(17, 115)], [(10, 46), (23, 47)], [(10, 24), (35, 25)], [(19, 15), (35, 16)]], [[(17, 115), (1, 116)], [(14, 46), (21, 47)], [(29, 24), (19, 25)], [(11, 15), (46, 16)]], [[(13, 115), (6, 116)], [(14, 46), (23, 47)], [(44, 24), (7, 25)], [(59, 16), (1, 17)]], [[(12, 121), (7, 122)], [(12, 47), (26, 48)], [(39, 24), (14, 25)], [(22, 15), (41, 16)]], [[(6, 121), (14, 122)], [(6, 47), (34, 48)], [(46, 24), (10, 25)], [(2, 15), (64, 16)]], [[(17, 122), (4, 123)], [(29, 46), (14, 47)], [(49, 24), (10, 25)], [(24, 15), (46, 16)]], [[(4, 122), (18, 123)], [(13, 46), (32, 47)], [(48, 24), (14, 25)], [(42, 15), (32, 16)]], [[(20, 117), (4, 118)], [(40, 47), (7, 48)], [(43, 24), (22, 25)], [(10, 15), (67, 16)]], [[(19, 118), (6, 119)], [(18, 47), (31, 48)], [(34, 24), (34, 25)], [(20, 15), (61, 16)]]]

    private var image:UIImage!
    private var imageSize:CGSize!
    private var origin:CGPoint!
    private var pixelArray:[[Bool]]!
    private var bitSize:Int!
    
    private var totalBitLength:Int!
    
    private var version:Int!
    
    private var bits:[[Bool]]!
    
    private var lookUpTable:[[(String, Int)]]!
    
    private var totalDataBits:Int!
    
    private var maskedFormat1Bits:[Int]!
    private var maskedFormat2Bits:[Int]!
    private var version1Bits:[Int]!
    private var version2Bits:[Int]!
    private var dataBits:[Int]!
    
    private var interleavedDataBits:[Int]!
    
    func getMessage(image:UIImage) -> String
    {
        self.loadImagePixels(image: image)
        self.findOrigin()
        self.getBitSize()
        self.findQRVersion()
        self.getBits()
        self.getLookUpTable()
        self.extractBits()
        self.decodeTheBits()
        var str = self.getReadableData()
        print(str)
        return str
        
    }
    
    //Load the pixels into an array
    private func loadImagePixels(image:UIImage)
    {
        self.image = image.blackWhite()
        
        imageSize = self.image.size
        
        let ySize = imageSize.width
        let xSize = imageSize.height
        
        pixelArray = []
        let innerPixelArray:[Bool] = []
        
        for i in 0..<Int(ySize)
        {
            pixelArray.append(innerPixelArray)
            for j in 0..<Int(xSize)
            {
                let point:CGPoint = CGPoint(x:CGFloat(j), y:CGFloat(i))
                
                if(self.image.getPixelColor(pos: point) == black)
                {
                    pixelArray[i].append(false)
                    
                }
                else
                {
                    pixelArray[i].append(true)
                }
                
                
            }
        }
        
        
    }
    
    //Find where the QR code starts
    private func findOrigin()
    {
        let ySize = imageSize.width
        let xSize = imageSize.height
        
        for i in 0..<Int(ySize)
        {
            for j in 0..<Int(xSize)
            {
                let point:CGPoint = CGPoint(x:CGFloat(j), y:CGFloat(i))
                if(!pixelArray[i][j])
                {
                    origin = point
                    return
                    
                }
                
                
            }
        }
        
    }
    
    //Gets the bit size by finding the smallest chunch of black pixels searche x and y direction
    private func getBitSize()
    {
        let ySize = imageSize.width
        let xSize = imageSize.height
        var size = 0
        
        for x in 0..<Int(xSize)
        {
            
            let point:CGPoint = CGPoint(x:CGFloat(x), y:CGFloat((origin?.y)!))
            if (image!.getPixelColor(pos: point) == black)
            {
                if(size > 0 && (bitSize == nil || size < bitSize!))
                {
                    bitSize = size
                    size = 0
                }
                
            }
            
        }
        
        for y in 0..<Int(ySize)
        {
            
            let point:CGPoint = CGPoint(x:CGFloat((origin?.x)!), y:CGFloat(y))
            if (image!.getPixelColor(pos: point) == black)
            {
                if(size > 0 && (bitSize == nil || size < bitSize!))
                {
                    bitSize = size
                    size = 0
                }
                
            }
            else
            {
                size += 1
            }
        }
        
        
        
        
    }
    
    //Get the QR version Support 1-40
    private func findQRVersion()
    {
        let xSize = imageSize.height
        
        var xLen = 0
        
        for x in 0..<Int(xSize)
        {
            let point:CGPoint = CGPoint(x:CGFloat(x), y:CGFloat((origin?.y)!))
            if (image!.getPixelColor(pos: point) == black)
            {
                xLen = x
            }
            
        }
        
        
        var bitLength = ((xLen - (Int((origin?.x)!)))/bitSize!)
        
        let error = (mod(x: (bitLength-21),m: 4))
        
        if (error == 3)
        {
            bitLength += 1
        }
            
        else if (error == 1)
        {
            bitLength -= 1
        }
            
        else if (error == 2)
        {
            print("Error Determining QR Version")
        }
        
        let qrVersion = ((bitLength-21)/4) + 1
        version = qrVersion
        
        totalBitLength = bitLength
    }
    
    //Get the bits (all the black squares)
    private func getBits()
    {
        bits = []
        let second:[Bool] = []
        
        for j in 0..<totalBitLength
        {
            bits.append(second)
            for i in 0..<totalBitLength
            {
                
                if(pixelArray[Int(Int((origin?.x)!) + (bitSize!/2) + (bitSize! * j))][Int(Int((origin?.y)!) + (bitSize!/2) + bitSize! * i)])
                {
                    bits[j].append(false)
                }
                else{
                    bits[j].append(true)
                }
                
            }
            
        }
        
        
        //Check to make sure we read the bits correctly
        //        var finalString = ""
        //        for j in 0..<Int(totalBitLength)
        //        {
        //            for i in 0..<Int(totalBitLength)
        //            {
        //                if(bits[j][i])
        //                {
        //                    finalString += "*"
        //                }
        //                else{
        //                    finalString += "-"
        //                }
        //            }
        //            finalString += "\n"
        //        }
        //
        //        //
        //        print(finalString)
    }
    
    
    //Create the lookup table
    private func getLookUpTable()
    {
        
        //Find the alignment coordinates, useful when image is crooked
        var alignmentCoordinates:[(Int,Int)] = []
        
        let coordValues = qrAlignment[version - 1]
        
        for x in coordValues
        {
            for y in coordValues
            {
                if( !(x == coordValues.min()) && y == coordValues.min() &&
                    !(x == coordValues.min()) && y == coordValues.max() &&
                    !(x == coordValues.max()) && y == coordValues.min())
                {
                    alignmentCoordinates.append((x,y))
                }
                
            }
        }
        
        //Create the lookup table
        
        lookUpTable = []
        
        let qrLookupSecond:[(String, Int)] = []
        
        totalDataBits = 0
        
        let yBitLength = totalBitLength
        
        var fCount = 0
        for j in 0..<Int(yBitLength!)
        {
            lookUpTable.append(qrLookupSecond)
            for i in 0..<Int(totalBitLength)
            {
                //Position Patterns
                if(i < 7 && j < 7)
                {
                    lookUpTable[j].append(("P", 0))
                }
                    
                else if(i >= (totalBitLength-7) && j < 7)
                {
                    lookUpTable[j].append(("P", 0))
                }
                    
                else if(i < 7 && j >= (yBitLength! - 7))
                {
                    lookUpTable[j].append(("P", 0))
                }
                    
                    //Blank Walls
                else if(i == 7 && j < 8)
                {
                    lookUpTable[j].append(("B", 0))
                }
                    
                else if(i < 8 && j == 7)
                {
                    lookUpTable[j].append(("B", 0))
                }
                    
                else if(i == totalBitLength-7-1 && j < 8)
                {
                    lookUpTable[j].append(("B", 0))
                }
                    
                else if(i >= totalBitLength-7-1 && j == 7)
                {
                    lookUpTable[j].append(("B", 0))
                }
                    
                else if(i == 7 && j >= (yBitLength!-7-1))
                {
                    lookUpTable[j].append(("B", 0))
                }
                    
                else if(i < 8 && j == (yBitLength!-7-1))
                {
                    lookUpTable[j].append(("B", 0))
                }
                    
                    //Allignment Patterns
                else if (insideAllignmentPattern(i: i,j: j, allignmentCoords: alignmentCoordinates))
                {
                    lookUpTable[j].append(("A", 0))
                }
                    
                    //Timing Patterns
                else if(i == 6)
                {
                    lookUpTable[j].append(("T", 0))
                }
                    
                else if(j == 6)
                {
                    lookUpTable[j].append(("T", 0))
                }
                    
                    //Format Bits
                    
                else if(i >= (totalBitLength-7-1) && j == 8)
                {
                    lookUpTable[j].append(("G", ((7-(i-(totalBitLength-7-1))))))
                }
                    
                else if(i == 8 && j < 9)
                {
                    var temp = 0
                    if(j < 6)
                    {
                        temp = j
                    }
                    else
                    {
                        temp = j-1
                    }
                    lookUpTable[j].append(("F", temp))
                    fCount += 1
                }
                else if(i < 8 && j == 8)
                {
                    fCount += 1
                    lookUpTable[j].append(("F", (i < 6 ? 14-i: 15-i)))
                }
                    
                else if(i == 8 && j == yBitLength!-7-1)
                {
                    lookUpTable[j].append(("D", 0))
                }
                    
                else if(i == 8 && j > yBitLength!-7-1)
                {
                    lookUpTable[j].append(("G", (j-(yBitLength!-7-1)+7)))
                }
                    
                    //Only for verson 7 or greater
                else if(version >= 7 && i >= totalBitLength-7-1-3 && j < 6)
                {
                    lookUpTable[j].append(("V", (i-(totalBitLength-7-1-3)+3*j)))
                }
                    
                else if(version >= 7 && i < 6 && j >= yBitLength!-7-1-3)
                {
                    lookUpTable[j].append(("R", (j-(yBitLength!-7-1-3)+3*i)))
                }
                    
                else
                {
                    lookUpTable[j].append((".", 0))
                    totalDataBits! += 1
                }
                
            }
        }
        //print("total Data Bits \(totalDataBits)")
        //############################################################
        
        //Add to the lookup table# Start bottom Right corner####################################
        
        var y = yBitLength! - 1
        var x = totalBitLength - 1
        var bitCounter = 7
        var byteCounter = 0
        var goingUp = true
        var symbol = "."
        
        var newX = 0
        var newY = 0
        
        var index = 0
        
        while (index < totalDataBits)
        {
            //Skip over timing bits
            if(x == 6)
            {
                x -= 1
                continue
            }
            
            if(lookUpTable[y][x].0 == ".")
            {
                lookUpTable[y][x] = (symbol, bitCounter+byteCounter*8)
                //print(qrLookup[y][x])
                bitCounter -= 1
                if (bitCounter < 0)
                {
                    byteCounter += 1
                    bitCounter = 7
                    
                    if((bitCounter + byteCounter * 8) == totalDataBits)
                    {
                        bitCounter -= (8 - (mod(x: totalDataBits, m: 8)))
                    }
                    if(symbol == "_")
                    {
                        symbol = "."
                    }
                    else
                    {
                        symbol = "_"
                    }
                }
                
                index += 1
            }
            
            
            //If odd column move left
            if ( (x > 6 && (mod(x: x+1, m: 2)) != 0) || (x < 6 && (mod(x: x, m: 2)) != 0) )
            {
                newX = x-1
                newY = y
            }
                
            //Even column - move up/down and right
            else
            {
                newX = x+1
                if(goingUp)
                {
                    newY = y-1
                }
                else
                {
                    newY = y + 1
                }
            }
            
            //Check if out of bounds move to the left and switch direction
            if ((newY < 0 || newY == yBitLength!))
            {
                goingUp = !goingUp
                newY = y
                newX -= 2
            }
            
            x = newX
            y = newY
            
        }
        
//        ////print out lookup table##########################
//        var lookUpTableprint = ""
//        for j in 0..<yBitLength!
//        {
//            for i in 0..<totalBitLength
//            {
//                if (qrLookup[j][i].0 == "." || qrLookup[j][i].0 == "_")
//                {
//                    lookUpTableprint += " \(qrLookup[j][i].1) "
//                }
//                else
//                {
//                    lookUpTableprint += " \(qrLookup[j][i].0) "
//                }
//            }
//            
//            lookUpTableprint += "\n"
//        }
//        
//        print(lookUpTableprint)
        
        
    }
    
    //Get the bits from the table
    private func extractBits()
    {
        maskedFormat1Bits = Array(repeating: 0, count: 15)
        maskedFormat2Bits = Array(repeating: 0, count: 15)
        
        version1Bits = Array(repeating: 0, count: 18)
        version2Bits = Array(repeating: 0, count: 18)
        
        interleavedDataBits = Array(repeating: 0, count: totalDataBits+5)
        for j in 0..<totalBitLength
        {
            for i in 0..<totalBitLength
            {
                let temp:(String, Int) = lookUpTable[j][i]

                if(temp.0 == "F")
                {
                    maskedFormat1Bits[temp.1] = bits[j][i] ? 1 : 0
                }
                    
                else if(temp.0 == "G")
                {
                    maskedFormat2Bits[temp.1] = bits[j][i] ? 1 : 0
                }
                else if(temp.0 == "V")
                {
                    version1Bits[temp.1] = bits[j][i] ? 1 : 0
                }
                else if(temp.0 == "R")
                {
                    version2Bits[temp.1] = bits[j][i] ? 1 : 0
                }
                else if(temp.0 == "V")
                {
                    version1Bits[temp.1] = bits[j][i] ? 1 : 0
                }
                    
                else if(temp.0 == "." || temp.0 == "_")
                {
                    interleavedDataBits[temp.1] = bits[j][i] ? 1 : 0
                }
                
            }
        }

    }
    
    //Unmask and decode the bits
    private func decodeTheBits()
    {
        //unmask and decode the format bits, unmask data bits
        var dECCLevelStr = ""
        var qrFormatMask:[Int] = [1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0]
        qrFormatMask.reverse()
        
        var format1Bits = xOr(a: qrFormatMask, b: maskedFormat1Bits)
        var format2Bits = xOr(a: qrFormatMask, b: maskedFormat2Bits)
        
        var dECCLevel = bitsToNumber(bits: Array(format1Bits[format1Bits.count - 2...format1Bits.count - 1]))
        
        if(dECCLevel == 0)
        {
            dECCLevelStr = "M"
        }
        else if(dECCLevel == 1)
        {
            dECCLevelStr = "L"
        }
        else if(dECCLevel == 2)
        {
            dECCLevelStr = "H"
        }
        else if(dECCLevel == 3)
        {
            dECCLevelStr = "Q"
        }
        
        let dMaskPattern = bitsToNumber(bits: Array(format1Bits[format1Bits.count -
            5...format1Bits.count - 3]))
        
        //print("Dmask Pattern \(dMaskPattern)")
        
        //Unmask the bits
        
        for j in 0..<totalBitLength
        {
            for i in 0..<totalBitLength
            {
                var temp:(String, Int) = lookUpTable[j][i]
                var xorBit = 0
                
                if(dMaskPattern == 0)
                {
                    let bit = 1*( ((i+j) % 2))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                    
                    
                }
                
                if(dMaskPattern == 1)
                {
                    let bit = 1*( (j % 2))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                    
                    
                }
                
                if(dMaskPattern == 2)
                {
                    let bit = 1*( (i % 3))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                }
                
                if(dMaskPattern == 3)
                {
                    let bit = 1*( ((i+j) % 3))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                }
                
                if(dMaskPattern == 4)
                {
                    let bit = 1*( (((j/2)+(i/3)) % 2))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                }
                
                if(dMaskPattern == 5)
                {
                    let bit = 1*( ( ((i*j) % 2) + ((i*j) % 3) ))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                }
                
                if(dMaskPattern == 6)
                {
                    let bit = 1*( ((((i*j) % 2) + ((i*j) % 3)) % 2))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                }
                
                if(dMaskPattern == 7)
                {
                    let bit = 1*( ( (((i*j) % 3) + ((i+j) % 2)) % 2))
                    
                    if bit == 0
                    {
                        xorBit = 1
                    }
                        
                    else
                    {
                        xorBit = 0
                    }
                    
                }
                
                if(temp.0 == "." || temp.0 == "_")
                {
                    interleavedDataBits[temp.1] ^= xorBit
                }
            }
        }
        
        
        //Find the ecc level From ISO Standard
        var eccIndex = -1
        if(dECCLevel == 1)
        {
            eccIndex = 0
        }
        if(dECCLevel == 0)
        {
            eccIndex = 1
        }
        if(dECCLevel == 3)
        {
            eccIndex = 2
        }
        if(dECCLevel == 2)
        {
            eccIndex = 3
        }
        
        let wordCounts = qrWordCount[version-1][eccIndex]
        
        var totalDataWords = 0
        
        var blocks:[[Int]] = []
        var ind = 0
        
        for w in wordCounts
        {
            for i in 0..<w.0
            {
                var block:[Int] = []
                for j in 0..<w.1
                {
                    block.append(ind)
                    ind += 1
                }
                blocks.append(block)

            }
            
            totalDataWords += w.1 * w.0
        }
        
        
        
        var dataWordSequence:[Int] = []
        var index2 = 0
        
        while dataWordSequence.count < totalDataWords
        {
            for j in 0..<blocks.count
            {
                if (index2 < blocks[j].count)
                {
                    dataWordSequence.append(blocks[j][index2])
                }
            }
            index2 += 1
        }
        
        dataBits = []
        var index3 = 0
        var indexChange = 0
        var bits:[Int] = []
        
        for index in dataWordSequence
        {
            indexChange = index*8
            let slice = interleavedDataBits[index3...index3+7]
            bits = Array(slice)
            bits = bits.reversed()

            dataBits.append(contentsOf: bits)
            index3 += 8
            
        }

    }
    
    //Extract the human readable message
    private func getReadableData() -> String
    {
        var index4 = 0

        var string = ""
        var dMode = -1
        while index4 < (totalDataBits - (totalDataBits % 8))
        {
            dMode = bitsToNumberMessage(bits: Array(dataBits[index4...index4+3]))
            
            
            index4 += 4
            
            //print (dMode)
            //print(dModeStr)
            
            
            var numCharBits = 0
            
            if(dMode == 0x1)
            {
                if (version < 10)
                {
                    numCharBits = 10
                }
                    
                else if (version < 27)
                {
                    numCharBits = 12
                }
                else
                {
                    numCharBits = 14
                }
                
            }
                
            else if(dMode == 0x2)
            {
                if (version < 10)
                {
                    numCharBits = 9
                }
                    
                else if (version < 27)
                {
                    numCharBits = 11
                }
                else
                {
                    numCharBits = 13
                }
            }
                
            else if(dMode == 0x4)
            {
                if (version < 10)
                {
                    numCharBits = 8
                }
                    
                else if (version < 27)
                {
                    numCharBits = 16
                }
                else
                {
                    numCharBits = 16
                }
            }
                
            else if(dMode == 0x8)
            {
                if (version < 10)
                {
                    numCharBits = 8
                }
                    
                else if (version < 27)
                {
                    numCharBits = 10
                }
                else
                {
                    numCharBits = 12
                }
            }
            
            var dlength = 0
            
            if(numCharBits > 0)
            {
                dlength = bitsToNumberMessage(bits: Array(dataBits[index4...index4+numCharBits-1]))
                index4 += numCharBits
                //print("Length \(dlength)")
            }
            
            if (dMode == 0x0)
            {
                print("oooops")
                break
            }
            
            print(dMode)
            
            if(dMode == 0x4)
            {
                var dByteValues:[Int] = []
                
                while (dlength > 0)
                {
                    dByteValues.append(bitsToNumberMessage(bits: Array(dataBits[index4...index4+7])))
                    index4 += 8
                    dlength -= 1
                }
                
                //print(dByteValues)
                
                
                for i in dByteValues
                {
                    string.append(Character(UnicodeScalar(i)!))
                }
            }
            
            
            
        }
            return string

    }
    
    
    
    private func bitsToNumberMessage(bits:[Int]) -> Int
    {
        var num = 0
        
        for i in 0..<bits.count
        {
            num |= (1 << (bits.count-1-i) * (bits[i]))
        }
        
        return num
    }
    
    
    
    private func xOr(a:[Int], b:[Int]) -> [Int]
    {
        var arr:[Int] = []
        for i in 0..<a.count
        {
            arr.append(a[i] ^ b[i])
        }
        
        return arr
        
    }
    
    private func bitsToNumber(bits:[Int]) -> Int
    {
        var num = 0
        
        for i in 0..<bits.count
        {
            num |= (1 << i)*(bits[i])
        }
        
        return num
    }
    
    private func insideAllignmentPattern(i:Int, j:Int , allignmentCoords:[(Int,Int)]) -> Bool
    {
        for a in allignmentCoords
        {
            if(abs(a.0-i) <= 2 && abs(a.1-j) <= 2)
            {
                return true
            }
        }
        return false
    }
    
    private func mod(x:Int, m:Int) -> Int
    {
        return (x%m + m)%m;
    }
}
