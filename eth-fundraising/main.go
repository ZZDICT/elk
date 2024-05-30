// 导入所需包
package main

import (
	"github.com/gin-gonic/gin" // 导入 Gin Web 框架
	"gorm.io/driver/mysql"     // 导入 GORM 的 MySQL 驱动
	"gorm.io/gorm"             // 导入 GORM ORM 库
	"math/rand"                // 导入随机数生成库
	"net/http"                 // 导入 HTTP 包，用于处理网络请求
	"path"                     // 导入路径处理包
	"strconv"                  // 导入字符串转换包
	"time"                     // 导入时间处理包
)

var db *gorm.DB // 定义一个全局的 GORM 数据库连接变量

func init() {
	// 初始化函数，这个用于在程序启动时执行一些准备工作

	// 创建一个数据库的连接
	var err error
	dsn := "root:root@tcp(127.0.0.1:3306)/eth-fundraising?charset=utf8mb4&parseTime=True&loc=Local"
	// 使用 GORM 和 MySQL 驱动打开数据库连接，并配置 GORM
	db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("无法连接到数据库") // 如果连接失败，则抛出异常
	}

	// 自动迁移 contractModel 数据结构到数据库中，创建对应的表结构
	err = db.AutoMigrate(&contractModel{})
	if err != nil {
		return // 如果迁移失败，则直接返回，不执行后续操作
	}
}

func main() {
	// 主函数

	router := gin.Default() // 创建一个默认的 Gin 路由器实例

	// 定义一个 API 分组，路径前缀为 /api/v1/contract
	v1 := router.Group("/api/v1/contract")
	{
		v1.POST("/", createContract)          // 在该分组下添加一个 POST 请求处理函数，用于创建合约
		v1.GET("/blockChainId", findContract) // 添加一个 GET 请求处理函数，通过 blockchainId 查找合约
		v1.GET("/", findAllContract)          // 添加一个 GET 请求处理函数，用于查找所有合约
	}

	// 定义一个文件处理分组，路径前缀为 /api/v1/file
	file := router.Group("/api/v1/file")
	{
		file.POST("/upload", Upload) // 在该分组下添加一个 POST 请求处理函数，用于文件上传
	}

	// 设置静态文件服务，将 ./files 目录下的文件映射到 /static 路径上
	router.StaticFS("/static", http.Dir("./files"))

	// 启动 Gin Web 服务，并监听默认端口（通常是 8080）
	// 如果有错误发生，则直接返回，不执行后续操作
	err := router.Run()
	if err != nil {
		return
	}
}

// Upload 函数用于处理文件上传请求
func Upload(c *gin.Context) {
	// 从请求中获取上传的文件
	file, err := c.FormFile("file")
	if err != nil {
		// 如果出现错误，则抛出异常并返回
		panic(err.Error())
		return
	}

	// 生成新的文件名，包括时间戳、随机数以及原始文件的扩展名
	newFileName := strconv.FormatInt(time.Now().Unix(), 10) + strconv.Itoa(rand.Intn(999999-100000)+10000) + path.Ext(file.Filename)

	// 将文件保存到服务器的指定目录下
	err = c.SaveUploadedFile(file, "./files/"+newFileName)
	if err != nil {
		// 如果保存失败，则返回错误信息
		c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "message": "文件上传失败！"})
		return
	}
	// 构造文件的访问地址并返回给客户端
	fileAddress := "/static/" + newFileName
	c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "url": fileAddress})
}

// contractModel 定义了合约模型的数据结构
type contractModel struct {
	gorm.Model
	BlockChainId    string `json:"blockChainId"`    // 区块链ID
	ContractAddress string `json:"contractAddress"` // 合约地址
}

// createContract 函数用于创建一个新的合约记录
func createContract(c *gin.Context) {
	// 从POST请求中提取表单数据，并创建一个新的contractModel实例
	contract := contractModel{BlockChainId: c.PostForm("blockChainId"), ContractAddress: c.PostForm("contractAddress")}
	// 将新的合约记录保存到数据库中
	db.Save(&contract)
	// 返回创建成功的响应
	c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "message": "Contract item created successfully!"})
}

// findContract 函数用于根据区块链ID查找合约记录
func findContract(c *gin.Context) {
	var contract contractModel         // 定义一个合约模型变量
	BlockChainId := c.Query("chainId") // 从查询参数中获取区块链ID
	// 在数据库中查找对应的合约记录
	db.First(&contract, "block_chain_id = ?", BlockChainId)
	if contract.ContractAddress != "" {
		// 如果找到了合约记录，则返回该记录
		c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "data": contract})
	} else {
		// 如果没有找到合约记录，则返回未找到的消息
		c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "message": "No contract found!"})
	}
}

// findAllContract 函数用于查找所有的合约记录
func findAllContract(c *gin.Context) {
	var contracts []contractModel // 定义一个合约模型切片变量
	// 在数据库中查找所有的合约记录
	db.Find(&contracts)
	if len(contracts) > 0 {
		// 如果找到了合约记录，则返回所有记录
		c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "data": contracts})
	} else {
		// 如果没有找到合约记录，则返回未找到的消息
		c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "message": "No contract found!"})
	}
}
