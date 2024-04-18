function! SpaceVim#api#iconv#codecs#_cp1026#import() abort

  return s:lib
endfunction

let s:tablebase = SpaceVim#api#iconv#codecs#tablebase#import()

let s:lib = {}

let s:lib.Codec = {}
call extend(s:lib.Codec, s:tablebase.Codec)
let s:lib.Codec.encoding = "CP1026"

let s:lib.Codec.decoding_table_maxlen = 1
let s:lib.Codec.encoding_table_maxlen = 1

let s:lib.Codec.decoding_table = {}
let s:lib.Codec.decoding_table["0"] = [0]
let s:lib.Codec.decoding_table["1"] = [1]
let s:lib.Codec.decoding_table["2"] = [2]
let s:lib.Codec.decoding_table["3"] = [3]
let s:lib.Codec.decoding_table["4"] = [156]
let s:lib.Codec.decoding_table["5"] = [9]
let s:lib.Codec.decoding_table["6"] = [134]
let s:lib.Codec.decoding_table["7"] = [127]
let s:lib.Codec.decoding_table["8"] = [151]
let s:lib.Codec.decoding_table["9"] = [141]
let s:lib.Codec.decoding_table["10"] = [142]
let s:lib.Codec.decoding_table["11"] = [11]
let s:lib.Codec.decoding_table["12"] = [12]
let s:lib.Codec.decoding_table["13"] = [13]
let s:lib.Codec.decoding_table["14"] = [14]
let s:lib.Codec.decoding_table["15"] = [15]
let s:lib.Codec.decoding_table["16"] = [16]
let s:lib.Codec.decoding_table["17"] = [17]
let s:lib.Codec.decoding_table["18"] = [18]
let s:lib.Codec.decoding_table["19"] = [19]
let s:lib.Codec.decoding_table["20"] = [157]
let s:lib.Codec.decoding_table["21"] = [133]
let s:lib.Codec.decoding_table["22"] = [8]
let s:lib.Codec.decoding_table["23"] = [135]
let s:lib.Codec.decoding_table["24"] = [24]
let s:lib.Codec.decoding_table["25"] = [25]
let s:lib.Codec.decoding_table["26"] = [146]
let s:lib.Codec.decoding_table["27"] = [143]
let s:lib.Codec.decoding_table["28"] = [28]
let s:lib.Codec.decoding_table["29"] = [29]
let s:lib.Codec.decoding_table["30"] = [30]
let s:lib.Codec.decoding_table["31"] = [31]
let s:lib.Codec.decoding_table["32"] = [128]
let s:lib.Codec.decoding_table["33"] = [129]
let s:lib.Codec.decoding_table["34"] = [130]
let s:lib.Codec.decoding_table["35"] = [131]
let s:lib.Codec.decoding_table["36"] = [132]
let s:lib.Codec.decoding_table["37"] = [10]
let s:lib.Codec.decoding_table["38"] = [23]
let s:lib.Codec.decoding_table["39"] = [27]
let s:lib.Codec.decoding_table["40"] = [136]
let s:lib.Codec.decoding_table["41"] = [137]
let s:lib.Codec.decoding_table["42"] = [138]
let s:lib.Codec.decoding_table["43"] = [139]
let s:lib.Codec.decoding_table["44"] = [140]
let s:lib.Codec.decoding_table["45"] = [5]
let s:lib.Codec.decoding_table["46"] = [6]
let s:lib.Codec.decoding_table["47"] = [7]
let s:lib.Codec.decoding_table["48"] = [144]
let s:lib.Codec.decoding_table["49"] = [145]
let s:lib.Codec.decoding_table["50"] = [22]
let s:lib.Codec.decoding_table["51"] = [147]
let s:lib.Codec.decoding_table["52"] = [148]
let s:lib.Codec.decoding_table["53"] = [149]
let s:lib.Codec.decoding_table["54"] = [150]
let s:lib.Codec.decoding_table["55"] = [4]
let s:lib.Codec.decoding_table["56"] = [152]
let s:lib.Codec.decoding_table["57"] = [153]
let s:lib.Codec.decoding_table["58"] = [154]
let s:lib.Codec.decoding_table["59"] = [155]
let s:lib.Codec.decoding_table["60"] = [20]
let s:lib.Codec.decoding_table["61"] = [21]
let s:lib.Codec.decoding_table["62"] = [158]
let s:lib.Codec.decoding_table["63"] = [26]
let s:lib.Codec.decoding_table["64"] = [32]
let s:lib.Codec.decoding_table["65"] = [160]
let s:lib.Codec.decoding_table["66"] = [226]
let s:lib.Codec.decoding_table["67"] = [228]
let s:lib.Codec.decoding_table["68"] = [224]
let s:lib.Codec.decoding_table["69"] = [225]
let s:lib.Codec.decoding_table["70"] = [227]
let s:lib.Codec.decoding_table["71"] = [229]
let s:lib.Codec.decoding_table["72"] = [123]
let s:lib.Codec.decoding_table["73"] = [241]
let s:lib.Codec.decoding_table["74"] = [199]
let s:lib.Codec.decoding_table["75"] = [46]
let s:lib.Codec.decoding_table["76"] = [60]
let s:lib.Codec.decoding_table["77"] = [40]
let s:lib.Codec.decoding_table["78"] = [43]
let s:lib.Codec.decoding_table["79"] = [33]
let s:lib.Codec.decoding_table["80"] = [38]
let s:lib.Codec.decoding_table["81"] = [233]
let s:lib.Codec.decoding_table["82"] = [234]
let s:lib.Codec.decoding_table["83"] = [235]
let s:lib.Codec.decoding_table["84"] = [232]
let s:lib.Codec.decoding_table["85"] = [237]
let s:lib.Codec.decoding_table["86"] = [238]
let s:lib.Codec.decoding_table["87"] = [239]
let s:lib.Codec.decoding_table["88"] = [236]
let s:lib.Codec.decoding_table["89"] = [223]
let s:lib.Codec.decoding_table["90"] = [286]
let s:lib.Codec.decoding_table["91"] = [304]
let s:lib.Codec.decoding_table["92"] = [42]
let s:lib.Codec.decoding_table["93"] = [41]
let s:lib.Codec.decoding_table["94"] = [59]
let s:lib.Codec.decoding_table["95"] = [94]
let s:lib.Codec.decoding_table["96"] = [45]
let s:lib.Codec.decoding_table["97"] = [47]
let s:lib.Codec.decoding_table["98"] = [194]
let s:lib.Codec.decoding_table["99"] = [196]
let s:lib.Codec.decoding_table["100"] = [192]
let s:lib.Codec.decoding_table["101"] = [193]
let s:lib.Codec.decoding_table["102"] = [195]
let s:lib.Codec.decoding_table["103"] = [197]
let s:lib.Codec.decoding_table["104"] = [91]
let s:lib.Codec.decoding_table["105"] = [209]
let s:lib.Codec.decoding_table["106"] = [351]
let s:lib.Codec.decoding_table["107"] = [44]
let s:lib.Codec.decoding_table["108"] = [37]
let s:lib.Codec.decoding_table["109"] = [95]
let s:lib.Codec.decoding_table["110"] = [62]
let s:lib.Codec.decoding_table["111"] = [63]
let s:lib.Codec.decoding_table["112"] = [248]
let s:lib.Codec.decoding_table["113"] = [201]
let s:lib.Codec.decoding_table["114"] = [202]
let s:lib.Codec.decoding_table["115"] = [203]
let s:lib.Codec.decoding_table["116"] = [200]
let s:lib.Codec.decoding_table["117"] = [205]
let s:lib.Codec.decoding_table["118"] = [206]
let s:lib.Codec.decoding_table["119"] = [207]
let s:lib.Codec.decoding_table["120"] = [204]
let s:lib.Codec.decoding_table["121"] = [305]
let s:lib.Codec.decoding_table["122"] = [58]
let s:lib.Codec.decoding_table["123"] = [214]
let s:lib.Codec.decoding_table["124"] = [350]
let s:lib.Codec.decoding_table["125"] = [39]
let s:lib.Codec.decoding_table["126"] = [61]
let s:lib.Codec.decoding_table["127"] = [220]
let s:lib.Codec.decoding_table["128"] = [216]
let s:lib.Codec.decoding_table["129"] = [97]
let s:lib.Codec.decoding_table["130"] = [98]
let s:lib.Codec.decoding_table["131"] = [99]
let s:lib.Codec.decoding_table["132"] = [100]
let s:lib.Codec.decoding_table["133"] = [101]
let s:lib.Codec.decoding_table["134"] = [102]
let s:lib.Codec.decoding_table["135"] = [103]
let s:lib.Codec.decoding_table["136"] = [104]
let s:lib.Codec.decoding_table["137"] = [105]
let s:lib.Codec.decoding_table["138"] = [171]
let s:lib.Codec.decoding_table["139"] = [187]
let s:lib.Codec.decoding_table["140"] = [125]
let s:lib.Codec.decoding_table["141"] = [96]
let s:lib.Codec.decoding_table["142"] = [166]
let s:lib.Codec.decoding_table["143"] = [177]
let s:lib.Codec.decoding_table["144"] = [176]
let s:lib.Codec.decoding_table["145"] = [106]
let s:lib.Codec.decoding_table["146"] = [107]
let s:lib.Codec.decoding_table["147"] = [108]
let s:lib.Codec.decoding_table["148"] = [109]
let s:lib.Codec.decoding_table["149"] = [110]
let s:lib.Codec.decoding_table["150"] = [111]
let s:lib.Codec.decoding_table["151"] = [112]
let s:lib.Codec.decoding_table["152"] = [113]
let s:lib.Codec.decoding_table["153"] = [114]
let s:lib.Codec.decoding_table["154"] = [170]
let s:lib.Codec.decoding_table["155"] = [186]
let s:lib.Codec.decoding_table["156"] = [230]
let s:lib.Codec.decoding_table["157"] = [184]
let s:lib.Codec.decoding_table["158"] = [198]
let s:lib.Codec.decoding_table["159"] = [164]
let s:lib.Codec.decoding_table["160"] = [181]
let s:lib.Codec.decoding_table["161"] = [246]
let s:lib.Codec.decoding_table["162"] = [115]
let s:lib.Codec.decoding_table["163"] = [116]
let s:lib.Codec.decoding_table["164"] = [117]
let s:lib.Codec.decoding_table["165"] = [118]
let s:lib.Codec.decoding_table["166"] = [119]
let s:lib.Codec.decoding_table["167"] = [120]
let s:lib.Codec.decoding_table["168"] = [121]
let s:lib.Codec.decoding_table["169"] = [122]
let s:lib.Codec.decoding_table["170"] = [161]
let s:lib.Codec.decoding_table["171"] = [191]
let s:lib.Codec.decoding_table["172"] = [93]
let s:lib.Codec.decoding_table["173"] = [36]
let s:lib.Codec.decoding_table["174"] = [64]
let s:lib.Codec.decoding_table["175"] = [174]
let s:lib.Codec.decoding_table["176"] = [162]
let s:lib.Codec.decoding_table["177"] = [163]
let s:lib.Codec.decoding_table["178"] = [165]
let s:lib.Codec.decoding_table["179"] = [183]
let s:lib.Codec.decoding_table["180"] = [169]
let s:lib.Codec.decoding_table["181"] = [167]
let s:lib.Codec.decoding_table["182"] = [182]
let s:lib.Codec.decoding_table["183"] = [188]
let s:lib.Codec.decoding_table["184"] = [189]
let s:lib.Codec.decoding_table["185"] = [190]
let s:lib.Codec.decoding_table["186"] = [172]
let s:lib.Codec.decoding_table["187"] = [124]
let s:lib.Codec.decoding_table["188"] = [175]
let s:lib.Codec.decoding_table["189"] = [168]
let s:lib.Codec.decoding_table["190"] = [180]
let s:lib.Codec.decoding_table["191"] = [215]
let s:lib.Codec.decoding_table["192"] = [231]
let s:lib.Codec.decoding_table["193"] = [65]
let s:lib.Codec.decoding_table["194"] = [66]
let s:lib.Codec.decoding_table["195"] = [67]
let s:lib.Codec.decoding_table["196"] = [68]
let s:lib.Codec.decoding_table["197"] = [69]
let s:lib.Codec.decoding_table["198"] = [70]
let s:lib.Codec.decoding_table["199"] = [71]
let s:lib.Codec.decoding_table["200"] = [72]
let s:lib.Codec.decoding_table["201"] = [73]
let s:lib.Codec.decoding_table["202"] = [173]
let s:lib.Codec.decoding_table["203"] = [244]
let s:lib.Codec.decoding_table["204"] = [126]
let s:lib.Codec.decoding_table["205"] = [242]
let s:lib.Codec.decoding_table["206"] = [243]
let s:lib.Codec.decoding_table["207"] = [245]
let s:lib.Codec.decoding_table["208"] = [287]
let s:lib.Codec.decoding_table["209"] = [74]
let s:lib.Codec.decoding_table["210"] = [75]
let s:lib.Codec.decoding_table["211"] = [76]
let s:lib.Codec.decoding_table["212"] = [77]
let s:lib.Codec.decoding_table["213"] = [78]
let s:lib.Codec.decoding_table["214"] = [79]
let s:lib.Codec.decoding_table["215"] = [80]
let s:lib.Codec.decoding_table["216"] = [81]
let s:lib.Codec.decoding_table["217"] = [82]
let s:lib.Codec.decoding_table["218"] = [185]
let s:lib.Codec.decoding_table["219"] = [251]
let s:lib.Codec.decoding_table["220"] = [92]
let s:lib.Codec.decoding_table["221"] = [249]
let s:lib.Codec.decoding_table["222"] = [250]
let s:lib.Codec.decoding_table["223"] = [255]
let s:lib.Codec.decoding_table["224"] = [252]
let s:lib.Codec.decoding_table["225"] = [247]
let s:lib.Codec.decoding_table["226"] = [83]
let s:lib.Codec.decoding_table["227"] = [84]
let s:lib.Codec.decoding_table["228"] = [85]
let s:lib.Codec.decoding_table["229"] = [86]
let s:lib.Codec.decoding_table["230"] = [87]
let s:lib.Codec.decoding_table["231"] = [88]
let s:lib.Codec.decoding_table["232"] = [89]
let s:lib.Codec.decoding_table["233"] = [90]
let s:lib.Codec.decoding_table["234"] = [178]
let s:lib.Codec.decoding_table["235"] = [212]
let s:lib.Codec.decoding_table["236"] = [35]
let s:lib.Codec.decoding_table["237"] = [210]
let s:lib.Codec.decoding_table["238"] = [211]
let s:lib.Codec.decoding_table["239"] = [213]
let s:lib.Codec.decoding_table["240"] = [48]
let s:lib.Codec.decoding_table["241"] = [49]
let s:lib.Codec.decoding_table["242"] = [50]
let s:lib.Codec.decoding_table["243"] = [51]
let s:lib.Codec.decoding_table["244"] = [52]
let s:lib.Codec.decoding_table["245"] = [53]
let s:lib.Codec.decoding_table["246"] = [54]
let s:lib.Codec.decoding_table["247"] = [55]
let s:lib.Codec.decoding_table["248"] = [56]
let s:lib.Codec.decoding_table["249"] = [57]
let s:lib.Codec.decoding_table["250"] = [179]
let s:lib.Codec.decoding_table["251"] = [219]
let s:lib.Codec.decoding_table["252"] = [34]
let s:lib.Codec.decoding_table["253"] = [217]
let s:lib.Codec.decoding_table["254"] = [218]
let s:lib.Codec.decoding_table["255"] = [159]

let s:lib.Codec.encoding_table = {}
let s:lib.Codec.encoding_table["0"] = [0]
let s:lib.Codec.encoding_table["1"] = [1]
let s:lib.Codec.encoding_table["2"] = [2]
let s:lib.Codec.encoding_table["3"] = [3]
let s:lib.Codec.encoding_table["156"] = [4]
let s:lib.Codec.encoding_table["9"] = [5]
let s:lib.Codec.encoding_table["134"] = [6]
let s:lib.Codec.encoding_table["127"] = [7]
let s:lib.Codec.encoding_table["151"] = [8]
let s:lib.Codec.encoding_table["141"] = [9]
let s:lib.Codec.encoding_table["142"] = [10]
let s:lib.Codec.encoding_table["11"] = [11]
let s:lib.Codec.encoding_table["12"] = [12]
let s:lib.Codec.encoding_table["13"] = [13]
let s:lib.Codec.encoding_table["14"] = [14]
let s:lib.Codec.encoding_table["15"] = [15]
let s:lib.Codec.encoding_table["16"] = [16]
let s:lib.Codec.encoding_table["17"] = [17]
let s:lib.Codec.encoding_table["18"] = [18]
let s:lib.Codec.encoding_table["19"] = [19]
let s:lib.Codec.encoding_table["157"] = [20]
let s:lib.Codec.encoding_table["133"] = [21]
let s:lib.Codec.encoding_table["8"] = [22]
let s:lib.Codec.encoding_table["135"] = [23]
let s:lib.Codec.encoding_table["24"] = [24]
let s:lib.Codec.encoding_table["25"] = [25]
let s:lib.Codec.encoding_table["146"] = [26]
let s:lib.Codec.encoding_table["143"] = [27]
let s:lib.Codec.encoding_table["28"] = [28]
let s:lib.Codec.encoding_table["29"] = [29]
let s:lib.Codec.encoding_table["30"] = [30]
let s:lib.Codec.encoding_table["31"] = [31]
let s:lib.Codec.encoding_table["128"] = [32]
let s:lib.Codec.encoding_table["129"] = [33]
let s:lib.Codec.encoding_table["130"] = [34]
let s:lib.Codec.encoding_table["131"] = [35]
let s:lib.Codec.encoding_table["132"] = [36]
let s:lib.Codec.encoding_table["10"] = [37]
let s:lib.Codec.encoding_table["23"] = [38]
let s:lib.Codec.encoding_table["27"] = [39]
let s:lib.Codec.encoding_table["136"] = [40]
let s:lib.Codec.encoding_table["137"] = [41]
let s:lib.Codec.encoding_table["138"] = [42]
let s:lib.Codec.encoding_table["139"] = [43]
let s:lib.Codec.encoding_table["140"] = [44]
let s:lib.Codec.encoding_table["5"] = [45]
let s:lib.Codec.encoding_table["6"] = [46]
let s:lib.Codec.encoding_table["7"] = [47]
let s:lib.Codec.encoding_table["144"] = [48]
let s:lib.Codec.encoding_table["145"] = [49]
let s:lib.Codec.encoding_table["22"] = [50]
let s:lib.Codec.encoding_table["147"] = [51]
let s:lib.Codec.encoding_table["148"] = [52]
let s:lib.Codec.encoding_table["149"] = [53]
let s:lib.Codec.encoding_table["150"] = [54]
let s:lib.Codec.encoding_table["4"] = [55]
let s:lib.Codec.encoding_table["152"] = [56]
let s:lib.Codec.encoding_table["153"] = [57]
let s:lib.Codec.encoding_table["154"] = [58]
let s:lib.Codec.encoding_table["155"] = [59]
let s:lib.Codec.encoding_table["20"] = [60]
let s:lib.Codec.encoding_table["21"] = [61]
let s:lib.Codec.encoding_table["158"] = [62]
let s:lib.Codec.encoding_table["26"] = [63]
let s:lib.Codec.encoding_table["32"] = [64]
let s:lib.Codec.encoding_table["160"] = [65]
let s:lib.Codec.encoding_table["226"] = [66]
let s:lib.Codec.encoding_table["228"] = [67]
let s:lib.Codec.encoding_table["224"] = [68]
let s:lib.Codec.encoding_table["225"] = [69]
let s:lib.Codec.encoding_table["227"] = [70]
let s:lib.Codec.encoding_table["229"] = [71]
let s:lib.Codec.encoding_table["123"] = [72]
let s:lib.Codec.encoding_table["241"] = [73]
let s:lib.Codec.encoding_table["199"] = [74]
let s:lib.Codec.encoding_table["46"] = [75]
let s:lib.Codec.encoding_table["60"] = [76]
let s:lib.Codec.encoding_table["40"] = [77]
let s:lib.Codec.encoding_table["43"] = [78]
let s:lib.Codec.encoding_table["33"] = [79]
let s:lib.Codec.encoding_table["38"] = [80]
let s:lib.Codec.encoding_table["233"] = [81]
let s:lib.Codec.encoding_table["234"] = [82]
let s:lib.Codec.encoding_table["235"] = [83]
let s:lib.Codec.encoding_table["232"] = [84]
let s:lib.Codec.encoding_table["237"] = [85]
let s:lib.Codec.encoding_table["238"] = [86]
let s:lib.Codec.encoding_table["239"] = [87]
let s:lib.Codec.encoding_table["236"] = [88]
let s:lib.Codec.encoding_table["223"] = [89]
let s:lib.Codec.encoding_table["286"] = [90]
let s:lib.Codec.encoding_table["304"] = [91]
let s:lib.Codec.encoding_table["42"] = [92]
let s:lib.Codec.encoding_table["41"] = [93]
let s:lib.Codec.encoding_table["59"] = [94]
let s:lib.Codec.encoding_table["94"] = [95]
let s:lib.Codec.encoding_table["45"] = [96]
let s:lib.Codec.encoding_table["47"] = [97]
let s:lib.Codec.encoding_table["194"] = [98]
let s:lib.Codec.encoding_table["196"] = [99]
let s:lib.Codec.encoding_table["192"] = [100]
let s:lib.Codec.encoding_table["193"] = [101]
let s:lib.Codec.encoding_table["195"] = [102]
let s:lib.Codec.encoding_table["197"] = [103]
let s:lib.Codec.encoding_table["91"] = [104]
let s:lib.Codec.encoding_table["209"] = [105]
let s:lib.Codec.encoding_table["351"] = [106]
let s:lib.Codec.encoding_table["44"] = [107]
let s:lib.Codec.encoding_table["37"] = [108]
let s:lib.Codec.encoding_table["95"] = [109]
let s:lib.Codec.encoding_table["62"] = [110]
let s:lib.Codec.encoding_table["63"] = [111]
let s:lib.Codec.encoding_table["248"] = [112]
let s:lib.Codec.encoding_table["201"] = [113]
let s:lib.Codec.encoding_table["202"] = [114]
let s:lib.Codec.encoding_table["203"] = [115]
let s:lib.Codec.encoding_table["200"] = [116]
let s:lib.Codec.encoding_table["205"] = [117]
let s:lib.Codec.encoding_table["206"] = [118]
let s:lib.Codec.encoding_table["207"] = [119]
let s:lib.Codec.encoding_table["204"] = [120]
let s:lib.Codec.encoding_table["305"] = [121]
let s:lib.Codec.encoding_table["58"] = [122]
let s:lib.Codec.encoding_table["214"] = [123]
let s:lib.Codec.encoding_table["350"] = [124]
let s:lib.Codec.encoding_table["39"] = [125]
let s:lib.Codec.encoding_table["61"] = [126]
let s:lib.Codec.encoding_table["220"] = [127]
let s:lib.Codec.encoding_table["216"] = [128]
let s:lib.Codec.encoding_table["97"] = [129]
let s:lib.Codec.encoding_table["98"] = [130]
let s:lib.Codec.encoding_table["99"] = [131]
let s:lib.Codec.encoding_table["100"] = [132]
let s:lib.Codec.encoding_table["101"] = [133]
let s:lib.Codec.encoding_table["102"] = [134]
let s:lib.Codec.encoding_table["103"] = [135]
let s:lib.Codec.encoding_table["104"] = [136]
let s:lib.Codec.encoding_table["105"] = [137]
let s:lib.Codec.encoding_table["171"] = [138]
let s:lib.Codec.encoding_table["187"] = [139]
let s:lib.Codec.encoding_table["125"] = [140]
let s:lib.Codec.encoding_table["96"] = [141]
let s:lib.Codec.encoding_table["166"] = [142]
let s:lib.Codec.encoding_table["177"] = [143]
let s:lib.Codec.encoding_table["176"] = [144]
let s:lib.Codec.encoding_table["106"] = [145]
let s:lib.Codec.encoding_table["107"] = [146]
let s:lib.Codec.encoding_table["108"] = [147]
let s:lib.Codec.encoding_table["109"] = [148]
let s:lib.Codec.encoding_table["110"] = [149]
let s:lib.Codec.encoding_table["111"] = [150]
let s:lib.Codec.encoding_table["112"] = [151]
let s:lib.Codec.encoding_table["113"] = [152]
let s:lib.Codec.encoding_table["114"] = [153]
let s:lib.Codec.encoding_table["170"] = [154]
let s:lib.Codec.encoding_table["186"] = [155]
let s:lib.Codec.encoding_table["230"] = [156]
let s:lib.Codec.encoding_table["184"] = [157]
let s:lib.Codec.encoding_table["198"] = [158]
let s:lib.Codec.encoding_table["164"] = [159]
let s:lib.Codec.encoding_table["181"] = [160]
let s:lib.Codec.encoding_table["246"] = [161]
let s:lib.Codec.encoding_table["115"] = [162]
let s:lib.Codec.encoding_table["116"] = [163]
let s:lib.Codec.encoding_table["117"] = [164]
let s:lib.Codec.encoding_table["118"] = [165]
let s:lib.Codec.encoding_table["119"] = [166]
let s:lib.Codec.encoding_table["120"] = [167]
let s:lib.Codec.encoding_table["121"] = [168]
let s:lib.Codec.encoding_table["122"] = [169]
let s:lib.Codec.encoding_table["161"] = [170]
let s:lib.Codec.encoding_table["191"] = [171]
let s:lib.Codec.encoding_table["93"] = [172]
let s:lib.Codec.encoding_table["36"] = [173]
let s:lib.Codec.encoding_table["64"] = [174]
let s:lib.Codec.encoding_table["174"] = [175]
let s:lib.Codec.encoding_table["162"] = [176]
let s:lib.Codec.encoding_table["163"] = [177]
let s:lib.Codec.encoding_table["165"] = [178]
let s:lib.Codec.encoding_table["183"] = [179]
let s:lib.Codec.encoding_table["169"] = [180]
let s:lib.Codec.encoding_table["167"] = [181]
let s:lib.Codec.encoding_table["182"] = [182]
let s:lib.Codec.encoding_table["188"] = [183]
let s:lib.Codec.encoding_table["189"] = [184]
let s:lib.Codec.encoding_table["190"] = [185]
let s:lib.Codec.encoding_table["172"] = [186]
let s:lib.Codec.encoding_table["124"] = [187]
let s:lib.Codec.encoding_table["175"] = [188]
let s:lib.Codec.encoding_table["168"] = [189]
let s:lib.Codec.encoding_table["180"] = [190]
let s:lib.Codec.encoding_table["215"] = [191]
let s:lib.Codec.encoding_table["231"] = [192]
let s:lib.Codec.encoding_table["65"] = [193]
let s:lib.Codec.encoding_table["66"] = [194]
let s:lib.Codec.encoding_table["67"] = [195]
let s:lib.Codec.encoding_table["68"] = [196]
let s:lib.Codec.encoding_table["69"] = [197]
let s:lib.Codec.encoding_table["70"] = [198]
let s:lib.Codec.encoding_table["71"] = [199]
let s:lib.Codec.encoding_table["72"] = [200]
let s:lib.Codec.encoding_table["73"] = [201]
let s:lib.Codec.encoding_table["173"] = [202]
let s:lib.Codec.encoding_table["244"] = [203]
let s:lib.Codec.encoding_table["126"] = [204]
let s:lib.Codec.encoding_table["242"] = [205]
let s:lib.Codec.encoding_table["243"] = [206]
let s:lib.Codec.encoding_table["245"] = [207]
let s:lib.Codec.encoding_table["287"] = [208]
let s:lib.Codec.encoding_table["74"] = [209]
let s:lib.Codec.encoding_table["75"] = [210]
let s:lib.Codec.encoding_table["76"] = [211]
let s:lib.Codec.encoding_table["77"] = [212]
let s:lib.Codec.encoding_table["78"] = [213]
let s:lib.Codec.encoding_table["79"] = [214]
let s:lib.Codec.encoding_table["80"] = [215]
let s:lib.Codec.encoding_table["81"] = [216]
let s:lib.Codec.encoding_table["82"] = [217]
let s:lib.Codec.encoding_table["185"] = [218]
let s:lib.Codec.encoding_table["251"] = [219]
let s:lib.Codec.encoding_table["92"] = [220]
let s:lib.Codec.encoding_table["249"] = [221]
let s:lib.Codec.encoding_table["250"] = [222]
let s:lib.Codec.encoding_table["255"] = [223]
let s:lib.Codec.encoding_table["252"] = [224]
let s:lib.Codec.encoding_table["247"] = [225]
let s:lib.Codec.encoding_table["83"] = [226]
let s:lib.Codec.encoding_table["84"] = [227]
let s:lib.Codec.encoding_table["85"] = [228]
let s:lib.Codec.encoding_table["86"] = [229]
let s:lib.Codec.encoding_table["87"] = [230]
let s:lib.Codec.encoding_table["88"] = [231]
let s:lib.Codec.encoding_table["89"] = [232]
let s:lib.Codec.encoding_table["90"] = [233]
let s:lib.Codec.encoding_table["178"] = [234]
let s:lib.Codec.encoding_table["212"] = [235]
let s:lib.Codec.encoding_table["35"] = [236]
let s:lib.Codec.encoding_table["210"] = [237]
let s:lib.Codec.encoding_table["211"] = [238]
let s:lib.Codec.encoding_table["213"] = [239]
let s:lib.Codec.encoding_table["48"] = [240]
let s:lib.Codec.encoding_table["49"] = [241]
let s:lib.Codec.encoding_table["50"] = [242]
let s:lib.Codec.encoding_table["51"] = [243]
let s:lib.Codec.encoding_table["52"] = [244]
let s:lib.Codec.encoding_table["53"] = [245]
let s:lib.Codec.encoding_table["54"] = [246]
let s:lib.Codec.encoding_table["55"] = [247]
let s:lib.Codec.encoding_table["56"] = [248]
let s:lib.Codec.encoding_table["57"] = [249]
let s:lib.Codec.encoding_table["179"] = [250]
let s:lib.Codec.encoding_table["219"] = [251]
let s:lib.Codec.encoding_table["34"] = [252]
let s:lib.Codec.encoding_table["217"] = [253]
let s:lib.Codec.encoding_table["218"] = [254]
let s:lib.Codec.encoding_table["159"] = [255]
